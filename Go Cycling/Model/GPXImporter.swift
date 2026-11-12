//
//  GPXImporter.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2026-11-12.
//

import Foundation
import CoreData
import CoreLocation
import UniformTypeIdentifiers

// Imports bike rides from GPX files exported by Go Cycling or other apps
enum GPXImporter {

    static let gpxContentType = UTType(importedAs: "com.topografix.gpx", conformingTo: .xml)

    // Below this speed a track segment counts as stopped, matching the auto-pause threshold used while recording
    private static let movingSpeedThreshold: CLLocationSpeed = 0.5
    // Minimum time window used to smooth per-point speeds so GPS jitter doesn't create unrealistic top speeds
    private static let speedSmoothingWindow: TimeInterval = 5
    // Rides starting within this many seconds of an existing ride are treated as duplicates
    private static let duplicateTolerance: TimeInterval = 1

    struct ImportSummary {
        var importedCount = 0
        var duplicateCount = 0
        var failedFileNames: [String] = []

        var message: String {
            var parts: [String] = []
            parts.append(importedCount == 1 ? "Imported 1 ride." : "Imported \(importedCount) rides.")
            if duplicateCount > 0 {
                parts.append(duplicateCount == 1
                    ? "Skipped 1 ride that was already saved."
                    : "Skipped \(duplicateCount) rides that were already saved.")
            }
            if !failedFileNames.isEmpty {
                parts.append("Could not import: \(failedFileNames.joined(separator: ", ")). Files must contain a recorded track with timestamps.")
            }
            return parts.joined(separator: "\n\n")
        }
    }

    // A ride parsed from a GPX file, ready to be stored
    struct ParsedRide {
        let latitudes: [CLLocationDegrees]
        let longitudes: [CLLocationDegrees]
        let timestamps: [Date]
        let trackElevations: [CLLocationDistance]
        let speeds: [CLLocationSpeed]
        let distance: CLLocationDistance
        let startTime: Date
        let movingTime: TimeInterval
        let elapsedTime: TimeInterval
        let category: String
    }

    enum ImportError: Error {
        case unreadable
        case noTimedTrackPoints
    }

    // MARK: Importing

    // Parses each file and saves new rides on a background context. Calls completion on the main queue,
    // after the cycling records have been updated with the imported rides
    static func importFiles(at urls: [URL], container: NSPersistentContainer, completion: @escaping (ImportSummary) -> Void) {
        container.performBackgroundTask { context in
            var summary = ImportSummary()
            var savedRides: [ParsedRide] = []
            var batchStartTimes: [Date] = []

            for url in urls {
                let accessing = url.startAccessingSecurityScopedResource()
                defer {
                    if accessing { url.stopAccessingSecurityScopedResource() }
                }

                let rides: [ParsedRide]
                do {
                    let data = try Data(contentsOf: url)
                    rides = try parse(data: data)
                } catch {
                    print("GPX import failed for \(url.lastPathComponent): \(error)")
                    summary.failedFileNames.append(url.lastPathComponent)
                    continue
                }

                for ride in rides {
                    let isDuplicateInBatch = batchStartTimes.contains { abs($0.timeIntervalSince(ride.startTime)) <= duplicateTolerance }
                    if isDuplicateInBatch || rideExists(startingAt: ride.startTime, in: context) {
                        summary.duplicateCount += 1
                        continue
                    }

                    insert(ride, into: context)
                    batchStartTimes.append(ride.startTime)
                    savedRides.append(ride)
                }
            }

            do {
                if context.hasChanges {
                    try context.save()
                }
                summary.importedCount = savedRides.count
            } catch {
                print("GPX import save failed: \(error.localizedDescription)")
                savedRides = []
                summary.failedFileNames = urls.map { $0.lastPathComponent }
            }

            DispatchQueue.main.async {
                // Imported rides count towards totals, records and activity awards like recorded ones
                for ride in savedRides {
                    CyclingRecords.shared.updateCyclingRecords(speeds: ride.speeds, distance: ride.distance, startTime: ride.startTime, time: ride.movingTime)
                }
                completion(summary)
            }
        }
    }

    private static func rideExists(startingAt startTime: Date, in context: NSManagedObjectContext) -> Bool {
        let fetchRequest: NSFetchRequest<BikeRide> = BikeRide.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K >= %@ AND %K <= %@",
                                             #keyPath(BikeRide.cyclingStartTime), startTime.addingTimeInterval(-duplicateTolerance) as NSDate,
                                             #keyPath(BikeRide.cyclingStartTime), startTime.addingTimeInterval(duplicateTolerance) as NSDate)
        fetchRequest.fetchLimit = 1
        return ((try? context.count(for: fetchRequest)) ?? 0) > 0
    }

    private static func insert(_ ride: ParsedRide, into context: NSManagedObjectContext) {
        let bikeRide = BikeRide(context: context)
        bikeRide.cyclingLatitudes = ride.latitudes
        bikeRide.cyclingLongitudes = ride.longitudes
        bikeRide.cyclingSpeeds = ride.speeds
        bikeRide.cyclingDistance = ride.distance
        // The compact elevation array used by the statistics only holds valid readings
        bikeRide.cyclingElevations = ride.trackElevations.filter { $0.isFinite }
        bikeRide.cyclingTrackElevations = ride.trackElevations
        bikeRide.cyclingTimestamps = ride.timestamps
        bikeRide.cyclingStartTime = ride.startTime
        bikeRide.cyclingTime = ride.movingTime
        bikeRide.cyclingElapsedTime = NSNumber(value: ride.elapsedTime)
        bikeRide.cyclingAverageSpeed = NSNumber(value: MetricsFormatting.calculateAverageSpeed(speeds: ride.speeds, distance: ride.distance, time: ride.movingTime))
        bikeRide.cyclingRouteName = ride.category
    }

    // MARK: Parsing

    // Each <trk> becomes one ride; its segments are joined. Waypoints and planned routes (<rte>) are ignored
    static func parse(data: Data) throws -> [ParsedRide] {
        let delegate = GPXParserDelegate()
        let parser = XMLParser(data: data)
        parser.shouldProcessNamespaces = true
        parser.delegate = delegate
        guard parser.parse() else {
            throw ImportError.unreadable
        }

        let rides = delegate.tracks.compactMap { buildRide(from: $0, creator: delegate.creator) }
        if rides.isEmpty {
            throw ImportError.noTimedTrackPoints
        }
        return rides
    }

    private static func buildRide(from track: GPXParserDelegate.Track, creator: String?) -> ParsedRide? {
        // Points without a timestamp can't contribute to time or speed, so they are dropped
        let points = track.points.filter { $0.time != nil }
        guard points.count >= 2,
              let startTime = points.first?.time,
              let endTime = points.last?.time,
              endTime > startTime else {
            return nil
        }

        let locations = points.map { CLLocation(latitude: $0.latitude, longitude: $0.longitude) }
        let times = points.map { $0.time! }

        var distance: CLLocationDistance = 0
        var movingTime: TimeInterval = 0
        var cumulativeDistances: [CLLocationDistance] = [0]
        for index in 1..<points.count {
            let segmentDistance = locations[index].distance(from: locations[index - 1])
            let segmentTime = times[index].timeIntervalSince(times[index - 1])
            distance += segmentDistance
            cumulativeDistances.append(distance)
            if segmentTime > 0 && segmentDistance / segmentTime >= movingSpeedThreshold {
                movingTime += segmentTime
            }
        }

        // Prefer speeds recorded in the file; otherwise derive them over a short smoothing window
        var speeds: [CLLocationSpeed] = []
        var windowStart = 0
        for index in 0..<points.count {
            if let recordedSpeed = points[index].speed, recordedSpeed >= 0 {
                speeds.append(recordedSpeed)
                continue
            }
            while windowStart < index - 1 && times[index].timeIntervalSince(times[windowStart + 1]) >= speedSmoothingWindow {
                windowStart += 1
            }
            let windowTime = times[index].timeIntervalSince(times[windowStart])
            let windowDistance = cumulativeDistances[index] - cumulativeDistances[windowStart]
            speeds.append(windowTime > 0 ? windowDistance / windowTime : 0)
        }

        return ParsedRide(
            latitudes: points.map { $0.latitude },
            longitudes: points.map { $0.longitude },
            timestamps: times,
            trackElevations: points.map { $0.elevation ?? .nan },
            speeds: speeds,
            distance: distance,
            startTime: startTime,
            movingTime: movingTime,
            elapsedTime: endTime.timeIntervalSince(startTime),
            category: category(forTrackName: track.name, creator: creator)
        )
    }

    // Go Cycling exports use the ride's category as the track name, so restore it on re-import.
    // Track names from other apps ("Morning Ride", ...) would flood the category list, so they are left uncategorized
    private static func category(forTrackName name: String?, creator: String?) -> String {
        guard creator == GPXExporter.creatorName,
              let name = name?.trimmingCharacters(in: .whitespacesAndNewlines),
              !name.isEmpty,
              !name.hasPrefix(GPXExporter.uncategorizedTrackNamePrefix) else {
            return "Uncategorized"
        }
        return name
    }
}

// MARK: - XML parsing

private final class GPXParserDelegate: NSObject, XMLParserDelegate {

    struct Point {
        let latitude: CLLocationDegrees
        let longitude: CLLocationDegrees
        var elevation: CLLocationDistance?
        var time: Date?
        var speed: CLLocationSpeed?
    }

    struct Track {
        var name: String?
        var points: [Point] = []
    }

    private(set) var creator: String?
    private(set) var tracks: [Track] = []

    private var currentTrack: Track?
    private var currentPoint: Point?
    private var text = ""

    private let fractionalDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    private let dateFormatter = ISO8601DateFormatter()
    // Some apps omit the time zone; GPX times are UTC by definition
    private let noTimeZoneDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter
    }()

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        text = ""
        switch elementName {
        case "gpx":
            creator = attributeDict["creator"]
        case "trk":
            currentTrack = Track()
        case "trkpt":
            if currentTrack != nil,
               let latitude = attributeDict["lat"].flatMap(Double.init),
               let longitude = attributeDict["lon"].flatMap(Double.init),
               CLLocationCoordinate2DIsValid(CLLocationCoordinate2D(latitude: latitude, longitude: longitude)) {
                currentPoint = Point(latitude: latitude, longitude: longitude)
            }
        default:
            break
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        text += string
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        let value = text.trimmingCharacters(in: .whitespacesAndNewlines)
        text = ""

        if currentPoint != nil {
            switch elementName {
            case "ele":
                currentPoint?.elevation = Double(value)
            case "time":
                currentPoint?.time = parseDate(value)
            case "speed":
                // GPX 1.0 <speed> and the TrackPointExtension <gpxtpx:speed> are both in m/s
                currentPoint?.speed = Double(value)
            case "trkpt":
                if let point = currentPoint {
                    currentTrack?.points.append(point)
                }
                currentPoint = nil
            default:
                break
            }
            return
        }

        switch elementName {
        case "name":
            // Only the track's own name, not names of the file metadata or waypoints
            if currentTrack != nil && currentTrack?.name == nil {
                currentTrack?.name = value
            }
        case "trk":
            if let track = currentTrack {
                tracks.append(track)
            }
            currentTrack = nil
        default:
            break
        }
    }

    private func parseDate(_ string: String) -> Date? {
        return fractionalDateFormatter.date(from: string)
            ?? dateFormatter.date(from: string)
            ?? noTimeZoneDateFormatter.date(from: string)
    }
}

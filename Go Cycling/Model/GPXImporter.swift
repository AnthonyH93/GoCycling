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
    // Rides starting within this many seconds of each other are duplicates even if their time spans don't overlap
    private static let duplicateTolerance: TimeInterval = 1
    // How far back to look for an existing ride that could still overlap an imported one
    private static let longestRideLookback: TimeInterval = 2 * 24 * 60 * 60
    // A Go Cycling file's saved start time is trusted if it is at most this long before the first point
    private static let maximumStartToFirstPointGap: TimeInterval = 60 * 60

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
        // Nil when the file's times were estimated by an older Go Cycling export rather than recorded
        let timestamps: [Date]?
        let trackElevations: [CLLocationDistance]
        let speeds: [CLLocationSpeed]
        let distance: CLLocationDistance
        let startTime: Date
        let lastPointTime: Date
        let movingTime: TimeInterval
        // Nil when the times were estimated, since there is no real record of pauses
        let elapsedTime: TimeInterval?
        let category: String

        var timeSpan: TimeSpan { TimeSpan(start: startTime, end: max(lastPointTime, startTime)) }
    }

    // The period a ride covers. You can't record two different rides at once, so overlapping rides are the same ride
    struct TimeSpan {
        let start: Date
        let end: Date

        func isDuplicate(of other: TimeSpan) -> Bool {
            if abs(start.timeIntervalSince(other.start)) <= GPXImporter.duplicateTolerance {
                return true
            }
            return start < other.end && other.start < end
        }
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
                    let isDuplicateInBatch = savedRides.contains { ride.timeSpan.isDuplicate(of: $0.timeSpan) }
                    if isDuplicateInBatch || existingRideOverlaps(ride.timeSpan, in: context) {
                        summary.duplicateCount += 1
                        continue
                    }

                    insert(ride, into: context)
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

    private static func existingRideOverlaps(_ span: TimeSpan, in context: NSManagedObjectContext) -> Bool {
        // Only rides starting shortly before the imported ride ends could overlap it
        let fetchRequest: NSFetchRequest<BikeRide> = BikeRide.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K >= %@ AND %K <= %@",
                                             #keyPath(BikeRide.cyclingStartTime), span.start.addingTimeInterval(-longestRideLookback) as NSDate,
                                             #keyPath(BikeRide.cyclingStartTime), span.end.addingTimeInterval(duplicateTolerance) as NSDate)
        guard let candidates = try? context.fetch(fetchRequest) else {
            return false
        }
        return candidates.contains { existing in
            // Rides from before total time was saved only know their moving time, which can only underestimate the end
            let duration = existing.cyclingElapsedTime?.doubleValue ?? existing.cyclingTime
            let existingSpan = TimeSpan(start: existing.cyclingStartTime, end: existing.cyclingStartTime.addingTimeInterval(max(duration, 0)))
            return span.isDuplicate(of: existingSpan)
        }
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
        bikeRide.cyclingElapsedTime = ride.elapsedTime.map { NSNumber(value: $0) }
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

        let isGoCyclingFile = delegate.creator == GPXExporter.creatorName
        // Go Cycling exports one ride per file and saves its exact start time in the metadata
        let savedStartTime = isGoCyclingFile && delegate.tracks.count == 1 ? delegate.metadataTime : nil
        let rides = delegate.tracks.compactMap { buildRide(from: $0, isGoCyclingFile: isGoCyclingFile, savedStartTime: savedStartTime) }
        if rides.isEmpty {
            throw ImportError.noTimedTrackPoints
        }
        return rides
    }

    private static func buildRide(from track: GPXParserDelegate.Track, isGoCyclingFile: Bool, savedStartTime: Date?) -> ParsedRide? {
        // Points without a timestamp can't contribute to time or speed, so they are dropped,
        // keeping track of where each segment starts
        var points: [GPXParserDelegate.Point] = []
        var nextPointStartsSegment = false
        for var point in track.points {
            guard point.time != nil else {
                nextPointStartsSegment = nextPointStartsSegment || point.startsSegment
                continue
            }
            point.startsSegment = point.startsSegment || nextPointStartsSegment
            nextPointStartsSegment = false
            points.append(point)
        }

        guard points.count >= 2,
              let firstPointTime = points.first?.time,
              let endTime = points.last?.time,
              endTime > firstPointTime else {
            return nil
        }

        // Recorded rides start when Start is pressed, a few seconds before the first GPS point,
        // so use the saved start time when the file has one
        var startTime = firstPointTime
        if let savedStartTime = savedStartTime,
           savedStartTime <= firstPointTime,
           firstPointTime.timeIntervalSince(savedStartTime) <= maximumStartToFirstPointGap {
            startTime = savedStartTime
        }
        let timestampsEstimated = isGoCyclingFile && track.description == GPXExporter.estimatedTimestampsDescription

        let locations = points.map { CLLocation(latitude: $0.latitude, longitude: $0.longitude) }
        let times = points.map { $0.time! }

        var distance: CLLocationDistance = 0
        var movingTime: TimeInterval = 0
        var cumulativeDistances: [CLLocationDistance] = [0]
        for index in 1..<points.count {
            // The jump from the end of one track segment to the start of the next wasn't ridden, so it adds no distance
            let segmentDistance = points[index].startsSegment ? 0 : locations[index].distance(from: locations[index - 1])
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
            timestamps: timestampsEstimated ? nil : times,
            trackElevations: points.map { $0.elevation ?? .nan },
            speeds: speeds,
            distance: distance,
            startTime: startTime,
            lastPointTime: endTime,
            movingTime: movingTime,
            elapsedTime: timestampsEstimated ? nil : endTime.timeIntervalSince(startTime),
            category: category(forTrackName: track.name, isGoCyclingFile: isGoCyclingFile)
        )
    }

    // Go Cycling exports use the ride's category as the track name, so restore it on re-import.
    // Track names from other apps ("Morning Ride", ...) would flood the category list, so they are left uncategorized
    private static func category(forTrackName name: String?, isGoCyclingFile: Bool) -> String {
        guard isGoCyclingFile,
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
        // First point of a <trkseg>
        var startsSegment = false
    }

    struct Track {
        var name: String?
        var description: String?
        var points: [Point] = []
    }

    private(set) var creator: String?
    private(set) var metadataTime: Date?
    private(set) var tracks: [Track] = []

    private var currentTrack: Track?
    private var currentPoint: Point?
    private var isInMetadata = false
    private var nextPointStartsSegment = false
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
        case "metadata":
            isInMetadata = true
        case "trk":
            currentTrack = Track()
        case "trkseg":
            nextPointStartsSegment = true
        case "trkpt":
            if currentTrack != nil,
               let latitude = attributeDict["lat"].flatMap(Double.init),
               let longitude = attributeDict["lon"].flatMap(Double.init),
               CLLocationCoordinate2DIsValid(CLLocationCoordinate2D(latitude: latitude, longitude: longitude)) {
                currentPoint = Point(latitude: latitude, longitude: longitude, startsSegment: nextPointStartsSegment)
                nextPointStartsSegment = false
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
        case "metadata":
            isInMetadata = false
        case "time":
            if isInMetadata {
                metadataTime = parseDate(value)
            }
        case "name":
            // Only the track's own name, not names of the file metadata or waypoints
            if currentTrack != nil && currentTrack?.name == nil {
                currentTrack?.name = value
            }
        case "desc":
            if currentTrack != nil && currentTrack?.description == nil {
                currentTrack?.description = value
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

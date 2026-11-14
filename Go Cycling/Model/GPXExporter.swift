//
//  GPXExporter.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2026-11-12.
//

import Foundation
import CoreData
import CoreLocation

// Exported files waiting to be shared. Presented with .sheet(item:) so the share sheet always
// receives the files directly, rather than reading state that may not have propagated yet
struct ExportedFiles: Identifiable {
    let id = UUID()
    let urls: [URL]
}

// Builds GPX 1.1 files from saved bike rides so they can be backed up or imported into other apps
enum GPXExporter {

    private static let exportDirectoryName = "GPXExport"

    // MARK: File export

    // Writes a single ride to a GPX file in a fresh temporary directory and returns its URL
    static func exportFile(for ride: BikeRide) throws -> URL {
        let directory = try makeExportDirectory()
        return try writeFile(for: ride, in: directory, usedNames: [])
    }

    // Fetches every ride on a background context, writes one GPX file per ride and
    // calls completion on the main queue with the file URLs (empty if there was nothing to export)
    static func exportAllRides(container: NSPersistentContainer, completion: @escaping (Result<[URL], Error>) -> Void) {
        container.performBackgroundTask { context in
            let result: Result<[URL], Error>
            do {
                let fetchRequest: NSFetchRequest<BikeRide> = BikeRide.fetchRequest()
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(BikeRide.cyclingStartTime), ascending: true)]
                let rides = try context.fetch(fetchRequest)

                let directory = try makeExportDirectory()
                var usedNames = Set<String>()
                var urls: [URL] = []
                for ride in rides {
                    let url = try writeFile(for: ride, in: directory, usedNames: usedNames)
                    usedNames.insert(url.lastPathComponent)
                    urls.append(url)
                }
                result = .success(urls)
            } catch {
                result = .failure(error)
            }

            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    private static func makeExportDirectory() throws -> URL {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(exportDirectoryName, isDirectory: true)
        // Clear out files from any previous export so they don't accumulate
        if FileManager.default.fileExists(atPath: directory.path) {
            try FileManager.default.removeItem(at: directory)
        }
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    private static func writeFile(for ride: BikeRide, in directory: URL, usedNames: Set<String>) throws -> URL {
        let baseName = fileBaseName(for: ride)
        var fileName = "\(baseName).gpx"
        var suffix = 2
        while usedNames.contains(fileName) {
            fileName = "\(baseName)-\(suffix).gpx"
            suffix += 1
        }

        let url = directory.appendingPathComponent(fileName)
        try gpxString(for: ride).write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    private static func fileBaseName(for ride: BikeRide) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd_HHmm"
        return "GoCycling_\(formatter.string(from: ride.cyclingStartTime))"
    }

    // MARK: GPX generation

    static func gpxString(for ride: BikeRide) -> String {
        let latitudes = ride.cyclingLatitudes
        let longitudes = ride.cyclingLongitudes
        let pointCount = min(latitudes.count, longitudes.count)

        let timestamps = pointTimestamps(for: ride, pointCount: pointCount)
        let elevations = pointElevations(for: ride, pointCount: pointCount)

        let timeFormatter = ISO8601DateFormatter()
        timeFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let name = ride.cyclingRouteName.isEmpty || ride.cyclingRouteName == "Uncategorized"
            ? "Bike Ride \(MetricsFormatting.formatDateAndTime(date: ride.cyclingStartTime))"
            : ride.cyclingRouteName

        var gpx = """
        <?xml version="1.0" encoding="UTF-8"?>
        <gpx version="1.1" creator="Go Cycling" xmlns="http://www.topografix.com/GPX/1/1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd">
          <metadata>
            <name>\(escapeXML(name))</name>
            <time>\(timeFormatter.string(from: ride.cyclingStartTime))</time>
          </metadata>
          <trk>
            <name>\(escapeXML(name))</name>
            <type>cycling</type>

        """
        if timestamps.estimated {
            gpx += "    <desc>Point timestamps are estimated: this ride was recorded before Go Cycling saved per-point times.</desc>\n"
        }
        gpx += "    <trkseg>\n"

        for index in 0..<pointCount {
            gpx += "      <trkpt lat=\"\(String(format: "%.7f", latitudes[index]))\" lon=\"\(String(format: "%.7f", longitudes[index]))\">"
            if let elevation = elevations?[index], elevation.isFinite {
                gpx += "<ele>\(String(format: "%.1f", elevation))</ele>"
            }
            gpx += "<time>\(timeFormatter.string(from: timestamps.dates[index]))</time></trkpt>\n"
        }

        gpx += """
            </trkseg>
          </trk>
        </gpx>

        """
        return gpx
    }

    // Uses recorded timestamps when available. Older rides only have a start time and moving time,
    // so their points are spread across the moving time in proportion to distance travelled
    private static func pointTimestamps(for ride: BikeRide, pointCount: Int) -> (dates: [Date], estimated: Bool) {
        if let recorded = ride.cyclingTimestamps, recorded.count >= pointCount {
            return (Array(recorded.prefix(pointCount)), false)
        }

        guard pointCount > 0 else { return ([], true) }
        guard pointCount > 1 else { return ([ride.cyclingStartTime], true) }

        var cumulativeDistances: [CLLocationDistance] = [0]
        var previous = CLLocation(latitude: ride.cyclingLatitudes[0], longitude: ride.cyclingLongitudes[0])
        for index in 1..<pointCount {
            let current = CLLocation(latitude: ride.cyclingLatitudes[index], longitude: ride.cyclingLongitudes[index])
            cumulativeDistances.append(cumulativeDistances[index - 1] + current.distance(from: previous))
            previous = current
        }

        let totalDistance = cumulativeDistances[pointCount - 1]
        let duration = max(ride.cyclingTime, 0)
        let dates = (0..<pointCount).map { index -> Date in
            let fraction = totalDistance > 0
                ? cumulativeDistances[index] / totalDistance
                : Double(index) / Double(pointCount - 1)
            return ride.cyclingStartTime.addingTimeInterval(duration * fraction)
        }
        return (dates, true)
    }

    // Elevations are only usable if they line up with the coordinates. Older rides dropped inaccurate
    // readings, so their compact elevation array only lines up if no readings were dropped
    private static func pointElevations(for ride: BikeRide, pointCount: Int) -> [CLLocationDistance]? {
        if let track = ride.cyclingTrackElevations, track.count >= pointCount {
            return track
        }
        if ride.cyclingElevations.count == pointCount {
            return ride.cyclingElevations
        }
        return nil
    }

    private static func escapeXML(_ string: String) -> String {
        return string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&apos;")
    }
}

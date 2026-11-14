//
//  RideShareImage.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2026-11-13.
//

import SwiftUI
import MapKit

// The image layouts a ride can be shared as
enum RideShareStyle: String, CaseIterable, Identifiable {
    case map = "Map"
    case route = "Route"
    case stats = "Stats"

    var id: String { rawValue }
}

// Everything a share card needs, pulled out of the BikeRide and user preferences up front
struct RideShareContent {
    struct Stat: Identifiable {
        let label: String
        let value: String
        var id: String { label }
    }

    let coordinates: [CLLocationCoordinate2D]
    let title: String
    let dateText: String
    let distance: Stat
    let otherStats: [Stat]
    let accentColor: UIColor
    let appIcon: UIImage?
    let mapType: MKMapType

    var allStats: [Stat] { [distance] + otherStats }

    init(bikeRide: BikeRide, preferences: Preferences) {
        let latitudes = bikeRide.cyclingLatitudes
        let longitudes = bikeRide.cyclingLongitudes
        coordinates = (0..<min(latitudes.count, longitudes.count)).map {
            CLLocationCoordinate2D(latitude: latitudes[$0], longitude: longitudes[$0])
        }

        let hasCategory = preferences.namedRoutes && !bikeRide.cyclingRouteName.isEmpty && bikeRide.cyclingRouteName != "Uncategorized"
        title = hasCategory ? bikeRide.cyclingRouteName : "Bike Ride"
        dateText = MetricsFormatting.formatDateAndTime(date: bikeRide.cyclingStartTime)

        let usingMetric = preferences.usingMetric
        let distanceValue = bikeRide.cyclingDistance / 1000 * (usingMetric ? 1 : 0.621371)
        let speedValue = bikeRide.resolvedAverageSpeed * (usingMetric ? 3.6 : 2.23694)
        let elevationGain = MetricsFormatting.computeElevationGain(elevations: bikeRide.cyclingElevations) * (usingMetric ? 1 : 3.28084)

        distance = Stat(label: "Distance", value: String(format: "%.1f %@", distanceValue, usingMetric ? "km" : "mi"))
        otherStats = [
            Stat(label: "Time", value: RideShareContent.formatDuration(bikeRide.cyclingTime)),
            Stat(label: "Avg Speed", value: String(format: "%.1f %@", speedValue, usingMetric ? "km/h" : "mph")),
            Stat(label: "Elev Gain", value: String(format: "%.0f %@", elevationGain, usingMetric ? "m" : "ft")),
        ]

        accentColor = UserPreferences.convertColourChoiceToUIColor(colour: preferences.colourChoiceConverted)
        // Each app icon has a matching image asset, so the card shows whichever icon the user has chosen
        appIcon = UIImage(named: UIApplication.shared.alternateIconName ?? "Default")
        mapType = preferences.mapTypeChoiceConverted.mkMapType
    }

    // Compact durations that fit on the card, e.g. "1h 24m", "18m 05s" or "42s"
    static func formatDuration(_ time: TimeInterval) -> String {
        let totalSeconds = Int(time)
        let hours = totalSeconds / 3600
        let minutes = totalSeconds / 60 % 60
        let seconds = totalSeconds % 60
        if hours > 0 {
            return "\(hours)h \(String(format: "%02d", minutes))m"
        }
        if minutes > 0 {
            return "\(minutes)m \(String(format: "%02d", seconds))s"
        }
        return "\(seconds)s"
    }
}

// An image waiting to be shared, presented with .sheet(item:)
struct SharedImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

enum RideShareImageRenderer {

    // Cards are laid out at 360pt and rendered at 3x, giving a 1080 x 1080 image
    static let canvasSize = CGSize(width: 360, height: 360)
    static let renderScale: CGFloat = 3

    // MARK: Map snapshot

    // Renders a map of the ride with the route drawn on top. Calls completion on the main queue with nil
    // if there is no route or the snapshot fails (e.g. offline), in which case the card falls back to a plain background
    static func makeMapImage(for content: RideShareContent, completion: @escaping (UIImage?) -> Void) {
        let coordinates = content.coordinates
        guard coordinates.count > 1 else {
            completion(nil)
            return
        }

        let options = MKMapSnapshotter.Options()
        options.mapRect = mapRect(fitting: coordinates)
        options.size = canvasSize
        options.scale = renderScale
        options.mapType = content.mapType
        options.traitCollection = UITraitCollection(userInterfaceStyle: .dark)
        // Hide businesses and landmarks: they clutter the card and reveal more about where the ride was
        options.pointOfInterestFilter = .excludingAll

        MKMapSnapshotter(options: options).start(with: .main) { snapshot, error in
            guard let snapshot = snapshot else {
                print("Map snapshot failed: \(error?.localizedDescription ?? "unknown error")")
                completion(nil)
                return
            }

            let format = UIGraphicsImageRendererFormat()
            format.scale = renderScale
            let image = UIGraphicsImageRenderer(size: canvasSize, format: format).image { _ in
                snapshot.image.draw(at: .zero)

                let path = UIBezierPath()
                for (index, coordinate) in coordinates.enumerated() {
                    let point = snapshot.point(for: coordinate)
                    if index == 0 { path.move(to: point) } else { path.addLine(to: point) }
                }
                path.lineJoinStyle = .round
                path.lineCapStyle = .round

                // White casing keeps the route readable on any map colour
                UIColor.white.withAlphaComponent(0.9).setStroke()
                path.lineWidth = 6
                path.stroke()
                content.accentColor.setStroke()
                path.lineWidth = 3.5
                path.stroke()
            }
            completion(image)
        }
    }

    // A square map area around the route, shifted so the route sits above the stats overlay at the bottom
    private static func mapRect(fitting coordinates: [CLLocationCoordinate2D]) -> MKMapRect {
        let routeRect = MKPolyline(coordinates: coordinates, count: coordinates.count).boundingMapRect
        // Pad generously and keep a minimum size so very short rides aren't zoomed in to street level
        let minimumSide = MKMapPointsPerMeterAtLatitude(coordinates[0].latitude) * 600
        let side = max(max(routeRect.width, routeRect.height) * 1.9, minimumSide)
        // Map y grows southwards, so moving the centre south moves the route up slightly, away from the larger stats overlay
        let centerX = routeRect.midX
        let centerY = routeRect.midY + side * 0.04
        return MKMapRect(x: centerX - side / 2, y: centerY - side / 2, width: side, height: side)
    }

    // MARK: Card rendering

    // Renders a SwiftUI card to an image. Uses a hosting controller snapshot so it works on iOS 15
    // (SwiftUI's ImageRenderer requires iOS 16)
    static func render<Card: View>(_ card: Card) -> UIImage {
        // Ignore safe areas, otherwise the hosting controller insets the card by the status bar height
        let controller = UIHostingController(rootView: card.frame(width: canvasSize.width, height: canvasSize.height).ignoresSafeArea())
        controller.overrideUserInterfaceStyle = .dark
        controller.view.bounds = CGRect(origin: .zero, size: canvasSize)
        controller.view.backgroundColor = .black
        controller.view.setNeedsLayout()
        controller.view.layoutIfNeeded()

        let format = UIGraphicsImageRendererFormat()
        format.scale = renderScale
        format.opaque = true
        return UIGraphicsImageRenderer(size: canvasSize, format: format).image { _ in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

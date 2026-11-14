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

// Hides the start and end of routes in shared images, which are often the rider's home.
// Chosen in the share sheet, since how much to hide depends on who the image is for
enum RoutePrivacy {
    static let defaultDistance: CLLocationDistance = 200

    // The last distance chosen in the share sheet is remembered, starting at the default
    private static let storageKey = "rideShareImagePrivacyDistance"

    static var preferredDistance: CLLocationDistance {
        UserDefaults.standard.object(forKey: storageKey) != nil ? UserDefaults.standard.double(forKey: storageKey) : defaultDistance
    }

    static func savePreference(_ distance: CLLocationDistance) {
        UserDefaults.standard.set(distance, forKey: storageKey)
    }

    struct Option: Identifiable, Hashable {
        let metres: CLLocationDistance
        let label: String
        var id: CLLocationDistance { metres }
    }

    static func options(usingMetric: Bool) -> [Option] {
        if usingMetric {
            return [Option(metres: 0, label: "Off"), Option(metres: 200, label: "200 m"),
                    Option(metres: 500, label: "500 m"), Option(metres: 1000, label: "1 km")]
        }
        return [Option(metres: 0, label: "Off"), Option(metres: 160.9344, label: "0.1 mi"),
                Option(metres: 402.336, label: "0.25 mi"), Option(metres: 804.672, label: "0.5 mi")]
    }

    // The closest option in the user's units, so a distance chosen in one unit system still shows sensibly in the other
    static func nearestOption(to metres: CLLocationDistance, usingMetric: Bool) -> Option {
        let options = options(usingMetric: usingMetric)
        if metres <= 0 { return options[0] }
        return options.dropFirst().min { abs($0.metres - metres) < abs($1.metres - metres) } ?? options[0]
    }

    // Removes `distance` from each end of the route. Returns nil when nothing would be left,
    // since showing even a sliver of a short ride would reveal where it was
    static func trim(_ coordinates: [CLLocationCoordinate2D], distance: CLLocationDistance) -> [CLLocationCoordinate2D]? {
        guard distance > 0 else { return coordinates }
        guard coordinates.count > 1 else { return nil }

        var cumulative: [CLLocationDistance] = [0]
        for index in 1..<coordinates.count {
            let previous = CLLocation(latitude: coordinates[index - 1].latitude, longitude: coordinates[index - 1].longitude)
            let current = CLLocation(latitude: coordinates[index].latitude, longitude: coordinates[index].longitude)
            cumulative.append(cumulative[index - 1] + current.distance(from: previous))
        }

        let total = cumulative[cumulative.count - 1]
        guard total > distance * 2,
              let first = cumulative.firstIndex(where: { $0 >= distance }),
              let last = cumulative.lastIndex(where: { $0 <= total - distance }),
              last > first else {
            return nil
        }
        return Array(coordinates[first...last])
    }
}

// Light or dark version of a share card
enum RideShareAppearance: String {
    case light
    case dark

    var isDark: Bool { self == .dark }
    var toggled: RideShareAppearance { isDark ? .light : .dark }
    var userInterfaceStyle: UIUserInterfaceStyle { isDark ? .dark : .light }

    // Once the user picks an appearance in the share sheet it is remembered; until then it follows the system
    private static let storageKey = "rideShareImageAppearance"

    static func preferred(systemIsDark: Bool) -> RideShareAppearance {
        if let stored = UserDefaults.standard.string(forKey: storageKey), let appearance = RideShareAppearance(rawValue: stored) {
            return appearance
        }
        return systemIsDark ? .dark : .light
    }

    func savePreference() {
        UserDefaults.standard.set(rawValue, forKey: RideShareAppearance.storageKey)
    }
}

// Everything a share card needs, pulled out of the BikeRide and user preferences up front
struct RideShareContent {
    struct Stat: Identifiable {
        let label: String
        let value: String
        var id: String { label }
    }

    // The route with the privacy distance trimmed from each end; empty when the route is hidden
    let coordinates: [CLLocationCoordinate2D]
    // True when the ride is too short to show any of its route with the chosen privacy distance
    let routeHidden: Bool
    let title: String
    let dateText: String
    let distance: Stat
    let otherStats: [Stat]
    let accentColor: UIColor
    let appIcon: UIImage?
    let mapType: MKMapType

    var allStats: [Stat] { [distance] + otherStats }

    init(bikeRide: BikeRide, preferences: Preferences, privacyDistance: CLLocationDistance) {
        let latitudes = bikeRide.cyclingLatitudes
        let longitudes = bikeRide.cyclingLongitudes
        let fullRoute = (0..<min(latitudes.count, longitudes.count)).map {
            CLLocationCoordinate2D(latitude: latitudes[$0], longitude: longitudes[$0])
        }
        let trimmedRoute = RoutePrivacy.trim(fullRoute, distance: privacyDistance)
        coordinates = trimmedRoute ?? []
        routeHidden = trimmedRoute == nil

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
    static func makeMapImage(for content: RideShareContent, appearance: RideShareAppearance, completion: @escaping (UIImage?) -> Void) {
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
        options.traitCollection = UITraitCollection(userInterfaceStyle: appearance.userInterfaceStyle)
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

                // A contrasting casing keeps the route readable on any map and with any accent colour
                (appearance.isDark ? UIColor.white.withAlphaComponent(0.9) : UIColor.black.withAlphaComponent(0.6)).setStroke()
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
    static func render<Card: View>(_ card: Card, appearance: RideShareAppearance) -> UIImage {
        // Ignore safe areas, otherwise the hosting controller insets the card by the status bar height
        let controller = UIHostingController(rootView: card.frame(width: canvasSize.width, height: canvasSize.height).ignoresSafeArea())
        controller.overrideUserInterfaceStyle = appearance.userInterfaceStyle
        controller.view.bounds = CGRect(origin: .zero, size: canvasSize)
        controller.view.backgroundColor = appearance.isDark ? .black : .white
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

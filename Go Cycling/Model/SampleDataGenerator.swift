//
//  SampleDataGenerator.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2026-08-31.
//

#if DEBUG

import Foundation
import CoreData
import CoreLocation

// Debug only helper that fills Core Data with a plausible two year cycling history so that the
// statistics tab charts, heatmap, records and awards all have something to show for App Store
// screenshots. The whole file is compiled out of release builds.
enum SampleDataGenerator {

    // Loops are drawn around this point - change it to move the generated routes onto a nicer map
    static let baseCoordinate = CLLocationCoordinate2D(latitude: 49.2827, longitude: -123.1207)

    // Two full years, so that even the 1Y period has a populated previous period to compare against
    static let daysOfHistory = 730

    // Fixed seed keeps every run identical, so a screenshot can be retaken later and still match.
    // This particular value was picked so that every chart period's distance, elevation, time and
    // route totals all beat their previous period, which is what makes the mini card deltas green.
    private static let seed: UInt64 = 0x4C14976BC46

    // MARK: - Public entry points

    // Replaces all stored rides and statistics with a freshly generated history.
    // Must be called from the main thread, the completion is also delivered there.
    static func generate(completion: @escaping (Int) -> Void) {
        let persistenceController = PersistenceController.shared

        // Start from a clean slate so repeated runs don't stack duplicate history on top of each other
        persistenceController.deleteAllBikeRides()
        CyclingRecords.resetStatistics()

        persistenceController.container.performBackgroundTask { context in
            let blueprints = makeBlueprints()

            for blueprint in blueprints {
                let bikeRide = BikeRide(context: context)
                bikeRide.cyclingLatitudes = blueprint.latitudes
                bikeRide.cyclingLongitudes = blueprint.longitudes
                bikeRide.cyclingSpeeds = blueprint.speeds
                bikeRide.cyclingElevations = blueprint.elevations
                bikeRide.cyclingDistance = blueprint.distance
                bikeRide.cyclingStartTime = blueprint.startTime
                bikeRide.cyclingTime = blueprint.time
                bikeRide.cyclingRouteName = blueprint.routeName
                bikeRide.cyclingAverageSpeed = NSNumber(value: MetricsFormatting.calculateAverageSpeed(speeds: blueprint.speeds, distance: blueprint.distance, time: blueprint.time))
            }

            do {
                try context.save()
                print("Generated \(blueprints.count) sample bike rides")
            } catch {
                print("Error generating sample bike rides: \(error.localizedDescription)")
            }

            DispatchQueue.main.async {
                // Records live in UserDefaults rather than Core Data, so they have to be replayed ride by ride
                for blueprint in blueprints {
                    CyclingRecords.shared.updateCyclingRecords(
                        speeds: blueprint.speeds.map { Optional($0) },
                        distance: blueprint.distance,
                        startTime: blueprint.startTime,
                        time: blueprint.time)
                }
                completion(blueprints.count)
            }
        }
    }

    // MARK: - Ride blueprints

    struct RideBlueprint {
        let startTime: Date
        let distance: CLLocationDistance
        let time: TimeInterval
        let routeName: String
        let latitudes: [CLLocationDegrees]
        let longitudes: [CLLocationDegrees]
        let speeds: [CLLocationSpeed]
        let elevations: [CLLocationDistance]
    }

    private enum RideKind {
        case commute
        case commuteHome
        case tempo
        case hills
        case endurance

        var distanceRange: ClosedRange<CLLocationDistance> {
            switch self {
            case .commute, .commuteHome: return 10_500...17_500
            case .tempo:                 return 27_000...43_000
            case .hills:                 return 34_000...56_000
            case .endurance:             return 62_000...112_000
            }
        }

        // Metres per second - roughly 21-31 km/h depending on the kind of ride
        var averageSpeedRange: ClosedRange<CLLocationSpeed> {
            switch self {
            case .commute, .commuteHome: return 5.8...7.2
            case .tempo:                 return 7.2...8.6
            case .hills:                 return 6.0...7.1
            case .endurance:             return 6.9...8.1
            }
        }

        // Metres climbed per kilometre ridden
        var elevationGainPerKilometreRange: ClosedRange<CLLocationDistance> {
            switch self {
            case .commute, .commuteHome: return 4...9
            case .tempo:                 return 6...11
            case .hills:                 return 18...28
            case .endurance:             return 8...14
            }
        }

        // Hours past midnight
        var startHourRange: ClosedRange<Double> {
            switch self {
            case .commute:     return 7.0...8.6
            case .commuteHome: return 16.8...18.5
            case .tempo:       return 17.4...19.0
            case .hills:       return 8.0...10.5
            case .endurance:   return 7.5...9.75
            }
        }

        var climbCountRange: ClosedRange<Int> {
            switch self {
            case .commute, .commuteHome: return 2...4
            case .tempo:                 return 3...6
            case .hills:                 return 5...9
            case .endurance:             return 4...8
            }
        }

        func routeName(rng: inout SeededGenerator) -> String {
            // A few uncategorized rides keep the history tab looking like real usage
            if Double.random(in: 0...1, using: &rng) < 0.1 {
                return "Uncategorized"
            }
            switch self {
            case .commute, .commuteHome: return "Commute"
            case .tempo:                 return "Evening Tempo"
            case .hills:                 return "Hill Repeats"
            case .endurance:
                let names = ["Coastal Loop", "Sunday Long Ride", "Valley Century"]
                return names[Int.random(in: 0..<names.count, using: &rng)]
            }
        }
    }

    private static func makeBlueprints() -> [RideBlueprint] {
        var rng = SeededGenerator(seed: seed)
        var calendar = Calendar.current
        calendar.timeZone = .current

        let today = calendar.startOfDay(for: Date())
        var blueprints: [RideBlueprint] = []

        for dayOffset in (-(daysOfHistory - 1))...0 {
            guard let day = calendar.date(byAdding: .day, value: dayOffset, to: today) else { continue }

            let weekday = calendar.component(.weekday, from: day)
            let isWeekend = (weekday == 1 || weekday == 7)
            let dayOfYear = calendar.ordinality(of: .day, in: .year, for: day) ?? 180

            // Riding peaks in mid July and eases off over the winter
            let seasonal = 0.60 + 0.40 * (0.5 + 0.5 * cos(2 * Double.pi * Double(dayOfYear - 196) / 365.0))
            // Riding ramps up over the two years, so every chart period compares favourably against
            // the previous one and the mini card deltas all read green
            let progress = Double(dayOffset + daysOfHistory) / Double(daysOfHistory)
            let trend = 0.62 + 0.50 * pow(progress, 1.6)
            let probability = min(0.95, (isWeekend ? 0.90 : 0.78) * seasonal * trend)

            guard Double.random(in: 0...1, using: &rng) < probability else { continue }

            if isWeekend {
                let kind: RideKind = Double.random(in: 0...1, using: &rng) < 0.6 ? .endurance : .hills
                blueprints.append(makeRide(kind: kind, day: day, calendar: calendar, rng: &rng))
            } else {
                let kind: RideKind = Double.random(in: 0...1, using: &rng) < 0.65 ? .commute : .tempo
                blueprints.append(makeRide(kind: kind, day: day, calendar: calendar, rng: &rng))
                // Commuters ride home again, which gives the heatmap some two ride days
                if kind == .commute && Double.random(in: 0...1, using: &rng) < 0.55 {
                    blueprints.append(makeRide(kind: .commuteHome, day: day, calendar: calendar, rng: &rng))
                }
            }
        }

        return blueprints
    }

    private static func makeRide(kind: RideKind, day: Date, calendar: Calendar, rng: inout SeededGenerator) -> RideBlueprint {
        let distance = Double.random(in: kind.distanceRange, using: &rng)
        let averageSpeed = Double.random(in: kind.averageSpeedRange, using: &rng)
        let time = distance / averageSpeed
        let elevationGain = (distance / 1000) * Double.random(in: kind.elevationGainPerKilometreRange, using: &rng)

        let startHour = Double.random(in: kind.startHourRange, using: &rng)
        let startTime = calendar.date(byAdding: .second, value: Int(startHour * 3600), to: day) ?? day

        // One sample every ~15 seconds, bounded so that long rides don't bloat the stored arrays
        let sampleCount = min(400, max(60, Int(time / 15)))

        let routeName = kind.routeName(rng: &rng)
        let loop = makeLoop(distance: distance, sampleCount: sampleCount, rng: &rng)
        let speeds = makeSpeeds(averageSpeed: averageSpeed, sampleCount: sampleCount, rng: &rng)
        let climbCount = Int.random(in: kind.climbCountRange, using: &rng)
        let elevations = makeElevations(gain: elevationGain, climbCount: climbCount, sampleCount: sampleCount, rng: &rng)

        return RideBlueprint(
            startTime: startTime,
            distance: distance,
            time: time,
            routeName: routeName,
            latitudes: loop.latitudes,
            longitudes: loop.longitudes,
            speeds: speeds,
            elevations: elevations)
    }

    // MARK: - Series builders

    private static func makeSpeeds(averageSpeed: CLLocationSpeed, sampleCount: Int, rng: inout SeededGenerator) -> [CLLocationSpeed] {
        var speeds: [CLLocationSpeed] = []
        speeds.reserveCapacity(sampleCount)

        let phase = Double.random(in: 0...(2 * Double.pi), using: &rng)
        for index in 0..<sampleCount {
            let progress = Double(index) / Double(sampleCount - 1)
            let wave = 0.22 * sin(6 * Double.pi * progress + phase) + 0.10 * sin(19 * Double.pi * progress)
            let jitter = Double.random(in: -0.06...0.06, using: &rng)
            // The peaks stay above the ride average, which is what calculateAverageSpeed checks for
            speeds.append(max(1.5, averageSpeed * (1 + wave + jitter)))
        }

        return speeds
    }

    // Builds a profile of evenly spaced climbs whose total matches gain when run through
    // MetricsFormatting.computeElevationGain - each climb is well above that function's 2 metre
    // threshold and the jitter stays well below it, so nothing spurious is counted
    private static func makeElevations(gain: CLLocationDistance, climbCount: Int, sampleCount: Int, rng: inout SeededGenerator) -> [CLLocationDistance] {
        var elevations: [CLLocationDistance] = []
        elevations.reserveCapacity(sampleCount)

        let climbHeight = gain / Double(climbCount)
        let baseElevation = Double.random(in: 5...120, using: &rng)

        for index in 0..<sampleCount {
            let progress = Double(index) / Double(sampleCount - 1)
            let position = (progress * Double(climbCount)).truncatingRemainder(dividingBy: 1)
            // 60% of each climb is spent going up and 40% coming back down
            let profile = position < 0.6
                ? smoothStep(position / 0.6)
                : 1 - smoothStep((position - 0.6) / 0.4)
            let jitter = Double.random(in: -0.4...0.4, using: &rng)
            elevations.append(baseElevation + climbHeight * profile + jitter)
        }

        return elevations
    }

    // A wobbly loop back to the start, sized so that its perimeter is roughly the ride distance
    private static func makeLoop(distance: CLLocationDistance, sampleCount: Int, rng: inout SeededGenerator) -> (latitudes: [CLLocationDegrees], longitudes: [CLLocationDegrees]) {
        let radius = distance / (2 * Double.pi) * 0.85
        let rotation = Double.random(in: 0...(2 * Double.pi), using: &rng)
        let wobblePhase = Double.random(in: 0...(2 * Double.pi), using: &rng)
        let centreLatitude = baseCoordinate.latitude + Double.random(in: -0.02...0.02, using: &rng)
        let centreLongitude = baseCoordinate.longitude + Double.random(in: -0.02...0.02, using: &rng)

        let metresPerDegreeLatitude = 111_320.0
        let metresPerDegreeLongitude = 111_320.0 * cos(baseCoordinate.latitude * Double.pi / 180)

        var latitudes: [CLLocationDegrees] = []
        var longitudes: [CLLocationDegrees] = []
        latitudes.reserveCapacity(sampleCount)
        longitudes.reserveCapacity(sampleCount)

        for index in 0..<sampleCount {
            let angle = 2 * Double.pi * Double(index) / Double(sampleCount) + rotation
            let wobble = 1 + 0.18 * sin(3 * angle + wobblePhase) + 0.09 * sin(5 * angle)
            let offsetNorth = radius * wobble * sin(angle)
            let offsetEast = radius * wobble * cos(angle) * 0.75
            latitudes.append(centreLatitude + offsetNorth / metresPerDegreeLatitude)
            longitudes.append(centreLongitude + offsetEast / metresPerDegreeLongitude)
        }

        return (latitudes, longitudes)
    }

    private static func smoothStep(_ value: Double) -> Double {
        let clamped = min(1, max(0, value))
        return clamped * clamped * (3 - 2 * clamped)
    }

    // MARK: - Deterministic random number generator

    // SplitMix64, so that the same seed always produces the same history
    struct SeededGenerator: RandomNumberGenerator {
        private var state: UInt64

        init(seed: UInt64) {
            self.state = seed
        }

        mutating func next() -> UInt64 {
            state = state &+ 0x9E3779B97F4A7C15
            var z = state
            z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
            z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
            return z ^ (z >> 31)
        }
    }
}

#endif

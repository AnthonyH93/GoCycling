//
//  StatisticsChartsViewModel.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2026-05-23.
//

import Foundation

class StatisticsChartsViewModel: ObservableObject {
    @Published var currentPoints: [ChartDataPoint] = []
    @Published var previousPoints: [ChartDataPoint] = []
    @Published var heatmapData: [Date: Int] = [:]
    @Published var heatmapDistanceData: [Date: Double] = [:]
    @Published var heatmapTimeData: [Date: Double] = [:]
    @Published var speedPoints: [SpeedPoint] = []

    @Published var totalCurrentDistance: Double = 0
    @Published var totalCurrentTime: Double = 0
    @Published var totalCurrentRoutes: Int = 0
    @Published var totalPreviousDistance: Double = 0
    @Published var totalPreviousTime: Double = 0
    @Published var totalPreviousRoutes: Int = 0

    struct SpeedPoint: Identifiable {
        let id = UUID()
        let date: Date
        let speed: Double   // m/s
    }

    var distanceChangePct: Double {
        guard totalPreviousDistance > 0 else { return totalCurrentDistance > 0 ? 100 : 0 }
        return ((totalCurrentDistance - totalPreviousDistance) / totalPreviousDistance) * 100
    }

    var timeChangePct: Double {
        guard totalPreviousTime > 0 else { return totalCurrentTime > 0 ? 100 : 0 }
        return ((totalCurrentTime - totalPreviousTime) / totalPreviousTime) * 100
    }

    var routeCountChange: Int { totalCurrentRoutes - totalPreviousRoutes }

    var avgCurrentSpeed: Double {
        guard totalCurrentDistance > 0, totalCurrentTime > 0 else { return 0 }
        return totalCurrentDistance / totalCurrentTime
    }

    var avgPreviousSpeed: Double {
        guard totalPreviousDistance > 0, totalPreviousTime > 0 else { return 0 }
        return totalPreviousDistance / totalPreviousTime
    }

    var speedChangePct: Double {
        guard avgPreviousSpeed > 0 else { return avgCurrentSpeed > 0 ? 100 : 0 }
        return ((avgCurrentSpeed - avgPreviousSpeed) / avgPreviousSpeed) * 100
    }

    init(period: ChartPeriod) {
        loadData(for: period)
    }

    func loadData(for period: ChartPeriod) {
        var cal = Calendar.current
        cal.timeZone = .current

        let (currentRides, previousRides) = BikeRide.fetchRidesForPeriod(period, calendar: cal)

        currentPoints  = buildBuckets(rides: currentRides,  period: period, isCurrent: true,  calendar: cal)
        previousPoints = buildBuckets(rides: previousRides, period: period, isCurrent: false, calendar: cal)

        totalCurrentDistance  = currentRides.reduce(0)  { $0 + $1.cyclingDistance }
        totalCurrentTime      = currentRides.reduce(0)  { $0 + $1.cyclingTime }
        totalCurrentRoutes    = currentRides.count
        totalPreviousDistance = previousRides.reduce(0) { $0 + $1.cyclingDistance }
        totalPreviousTime     = previousRides.reduce(0) { $0 + $1.cyclingTime }
        totalPreviousRoutes   = previousRides.count

        heatmapData = [:]
        heatmapDistanceData = [:]
        heatmapTimeData = [:]
        for ride in currentRides {
            let day = cal.startOfDay(for: ride.cyclingStartTime)
            heatmapData[day, default: 0] += 1
            heatmapDistanceData[day, default: 0] += ride.cyclingDistance
            heatmapTimeData[day, default: 0] += ride.cyclingTime
        }

        speedPoints = currentRides
            .filter { $0.cyclingTime > 0 && $0.cyclingDistance > 0 }
            .map { SpeedPoint(date: $0.cyclingStartTime, speed: $0.cyclingDistance / $0.cyclingTime) }
            .sorted { $0.date < $1.date }

        #if DEBUG
        if totalCurrentRoutes == 0 {
            loadTestData(for: period)
        }
        #endif
    }

    // MARK: - Bucketing

    private func buildBuckets(rides: [BikeRide], period: ChartPeriod, isCurrent: Bool, calendar: Calendar) -> [ChartDataPoint] {
        let slots = bucketDates(for: period, isCurrent: isCurrent, calendar: calendar)
        var map: [Date: ChartDataPoint] = Dictionary(
            uniqueKeysWithValues: slots.map { ($0, ChartDataPoint(bucketDate: $0)) }
        )
        for ride in rides {
            if let key = bucketKey(for: ride.cyclingStartTime, period: period, slots: slots, calendar: calendar) {
                map[key]?.distance += ride.cyclingDistance
                map[key]?.time     += ride.cyclingTime
                map[key]?.routes   += 1
            }
        }
        return slots.compactMap { map[$0] }
    }

    private func bucketDates(for period: ChartPeriod, isCurrent: Bool, calendar: Calendar) -> [Date] {
        let today = calendar.startOfDay(for: Date())
        var dates: [Date] = []

        switch period {
        case .oneWeek:
            let base = isCurrent ? 0 : -7
            for i in 0..<7 {
                if let d = calendar.date(byAdding: .day, value: base - 6 + i, to: today) { dates.append(d) }
            }

        case .oneMonth:
            let base = isCurrent ? 0 : -30
            for i in 0..<30 {
                if let d = calendar.date(byAdding: .day, value: base - 29 + i, to: today) { dates.append(d) }
            }

        case .threeMonths:
            let base = isCurrent ? 0 : -91
            for i in 0..<13 {
                if let d = calendar.date(byAdding: .day, value: base - 84 + (i * 7), to: today) { dates.append(d) }
            }

        case .sixMonths:
            let base = isCurrent ? 0 : -182
            for i in 0..<26 {
                if let d = calendar.date(byAdding: .day, value: base - 175 + (i * 7), to: today) { dates.append(d) }
            }

        case .yearToDate:
            let currentYear  = calendar.component(.year,  from: today)
            let currentMonth = calendar.component(.month, from: today)
            let targetYear   = isCurrent ? currentYear : currentYear - 1
            for month in 1...max(1, currentMonth) {
                var c = DateComponents(); c.year = targetYear; c.month = month; c.day = 1
                if let d = calendar.date(from: c) { dates.append(d) }
            }

        case .oneYear:
            let monthOffset = isCurrent ? 0 : -12
            for i in 0..<12 {
                let back = -(11 - i) + monthOffset
                if let d = calendar.date(byAdding: .month, value: back, to: today) {
                    var c = calendar.dateComponents([.year, .month], from: d)
                    c.day = 1
                    if let start = calendar.date(from: c) { dates.append(start) }
                }
            }
        }

        return dates
    }

    private func bucketKey(for date: Date, period: ChartPeriod, slots: [Date], calendar: Calendar) -> Date? {
        switch period {
        case .oneWeek, .oneMonth:
            let day = calendar.startOfDay(for: date)
            return slots.first { calendar.isDate($0, inSameDayAs: day) }

        case .threeMonths, .sixMonths:
            let day = calendar.startOfDay(for: date)
            for i in 0..<slots.count {
                let end = calendar.date(byAdding: .day, value: 7, to: slots[i]) ?? slots[i]
                if day >= slots[i] && day < end { return slots[i] }
            }
            return nil

        case .yearToDate, .oneYear:
            let rideMonth = calendar.component(.month, from: date)
            let rideYear  = calendar.component(.year,  from: date)
            return slots.first {
                calendar.component(.month, from: $0) == rideMonth &&
                calendar.component(.year,  from: $0) == rideYear
            }
        }
    }

    // MARK: - Test Data

    #if DEBUG
    private func loadTestData(for period: ChartPeriod) {
        var cal = Calendar.current
        cal.timeZone = .current
        let today = cal.startOfDay(for: Date())

        func daysAgo(_ n: Int) -> Date { cal.date(byAdding: .day, value: -n, to: today) ?? today }
        func monthsAgo(_ n: Int) -> Date {
            var c = DateComponents(); c.month = -n
            let d = cal.date(byAdding: c, to: today) ?? today
            return cal.startOfDay(for: d)
        }

        // km → meters, minutes → seconds helpers
        func km(_ v: Double) -> Double { v * 1000 }
        func mins(_ v: Double) -> Double { v * 60 }

        switch period {
        case .oneWeek:
            currentPoints = [
                ChartDataPoint(bucketDate: daysAgo(6), distance: km(18.4), time: mins(52),  routes: 1),
                ChartDataPoint(bucketDate: daysAgo(5), distance: 0,        time: 0,         routes: 0),
                ChartDataPoint(bucketDate: daysAgo(4), distance: km(27.1), time: mins(78),  routes: 1),
                ChartDataPoint(bucketDate: daysAgo(3), distance: 0,        time: 0,         routes: 0),
                ChartDataPoint(bucketDate: daysAgo(2), distance: km(12.6), time: mins(38),  routes: 1),
                ChartDataPoint(bucketDate: daysAgo(1), distance: 0,        time: 0,         routes: 0),
                ChartDataPoint(bucketDate: daysAgo(0), distance: km(32.0), time: mins(91),  routes: 1),
            ]
            previousPoints = [
                ChartDataPoint(bucketDate: daysAgo(13), distance: km(14.2), time: mins(43), routes: 1),
                ChartDataPoint(bucketDate: daysAgo(12), distance: 0,        time: 0,        routes: 0),
                ChartDataPoint(bucketDate: daysAgo(11), distance: km(22.7), time: mins(65), routes: 1),
                ChartDataPoint(bucketDate: daysAgo(10), distance: 0,        time: 0,        routes: 0),
                ChartDataPoint(bucketDate: daysAgo(9),  distance: km(31.5), time: mins(90), routes: 1),
                ChartDataPoint(bucketDate: daysAgo(8),  distance: 0,        time: 0,        routes: 0),
                ChartDataPoint(bucketDate: daysAgo(7),  distance: 0,        time: 0,        routes: 0),
            ]
            totalCurrentDistance  = currentPoints.reduce(0)  { $0 + $1.distance }
            totalCurrentTime      = currentPoints.reduce(0)  { $0 + $1.time }
            totalCurrentRoutes    = currentPoints.reduce(0)  { $0 + $1.routes }
            totalPreviousDistance = previousPoints.reduce(0) { $0 + $1.distance }
            totalPreviousTime     = previousPoints.reduce(0) { $0 + $1.time }
            totalPreviousRoutes   = previousPoints.reduce(0) { $0 + $1.routes }

        case .oneMonth:
            var cPts: [ChartDataPoint] = []
            let rideOffsets = [0, 2, 4, 7, 9, 11, 14, 16, 18, 21, 23, 25, 27, 29]
            let distances: [Double] = [32, 18, 25, 41, 15, 28, 22, 36, 19, 27, 33, 21, 29, 24]
            let times:     [Double] = [91, 52, 71, 117, 43, 80, 63, 102, 54, 77, 94, 60, 83, 68]
            for (i, offset) in rideOffsets.enumerated() {
                cPts.append(ChartDataPoint(bucketDate: daysAgo(offset), distance: km(distances[i]), time: mins(times[i]), routes: 1))
            }
            currentPoints = cPts
            previousPoints = [
                ChartDataPoint(bucketDate: daysAgo(33), distance: km(22), time: mins(63), routes: 1),
                ChartDataPoint(bucketDate: daysAgo(37), distance: km(31), time: mins(89), routes: 1),
                ChartDataPoint(bucketDate: daysAgo(42), distance: km(18), time: mins(51), routes: 1),
                ChartDataPoint(bucketDate: daysAgo(46), distance: km(27), time: mins(77), routes: 1),
                ChartDataPoint(bucketDate: daysAgo(51), distance: km(35), time: mins(100), routes: 1),
                ChartDataPoint(bucketDate: daysAgo(55), distance: km(20), time: mins(57), routes: 1),
                ChartDataPoint(bucketDate: daysAgo(58), distance: km(29), time: mins(82), routes: 1),
            ]
            totalCurrentDistance  = currentPoints.reduce(0)  { $0 + $1.distance }
            totalCurrentTime      = currentPoints.reduce(0)  { $0 + $1.time }
            totalCurrentRoutes    = currentPoints.count
            totalPreviousDistance = previousPoints.reduce(0) { $0 + $1.distance }
            totalPreviousTime     = previousPoints.reduce(0) { $0 + $1.time }
            totalPreviousRoutes   = previousPoints.count

        case .threeMonths:
            let weeklyDist: [Double] = [45, 0, 62, 38, 71, 55, 0, 83, 47, 60, 78, 32, 91]
            let weeklyTime: [Double] = [128, 0, 177, 109, 202, 157, 0, 237, 134, 171, 222, 91, 260]
            let slots = bucketDates(for: .threeMonths, isCurrent: true, calendar: cal)
            currentPoints = slots.enumerated().map { i, d in
                let idx = min(i, weeklyDist.count - 1)
                return ChartDataPoint(bucketDate: d, distance: km(weeklyDist[idx]), time: mins(weeklyTime[idx]), routes: weeklyDist[idx] > 0 ? Int(weeklyDist[idx] / 20) + 1 : 0)
            }
            let prevSlots = bucketDates(for: .threeMonths, isCurrent: false, calendar: cal)
            let prevDist: [Double] = [30, 58, 0, 44, 67, 80, 0, 39, 72, 51, 0, 68, 43]
            previousPoints = prevSlots.enumerated().map { i, d in
                let idx = min(i, prevDist.count - 1)
                return ChartDataPoint(bucketDate: d, distance: km(prevDist[idx]), time: mins(prevDist[idx] * 2.85), routes: prevDist[idx] > 0 ? Int(prevDist[idx] / 20) + 1 : 0)
            }
            totalCurrentDistance  = currentPoints.reduce(0)  { $0 + $1.distance }
            totalCurrentTime      = currentPoints.reduce(0)  { $0 + $1.time }
            totalCurrentRoutes    = currentPoints.reduce(0)  { $0 + $1.routes }
            totalPreviousDistance = previousPoints.reduce(0) { $0 + $1.distance }
            totalPreviousTime     = previousPoints.reduce(0) { $0 + $1.time }
            totalPreviousRoutes   = previousPoints.reduce(0) { $0 + $1.routes }

        case .sixMonths:
            let slots = bucketDates(for: .sixMonths, isCurrent: true, calendar: cal)
            let pattern: [Double] = [0, 38, 61, 22, 74, 55, 0, 83, 47, 29, 68, 90, 41, 55, 0, 72, 38, 65, 88, 47, 0, 59, 76, 31, 84, 52]
            currentPoints = slots.enumerated().map { i, d in
                let v = i < pattern.count ? pattern[i] : 0.0
                return ChartDataPoint(bucketDate: d, distance: km(v), time: mins(v * 2.85), routes: v > 0 ? Int(v / 18) + 1 : 0)
            }
            let prevSlots = bucketDates(for: .sixMonths, isCurrent: false, calendar: cal)
            let prevPat: [Double] = [42, 0, 55, 31, 68, 44, 77, 0, 35, 62, 49, 71, 0, 38, 85, 52, 0, 67, 43, 79, 28, 61, 47, 74, 0, 56]
            previousPoints = prevSlots.enumerated().map { i, d in
                let v = i < prevPat.count ? prevPat[i] : 0.0
                return ChartDataPoint(bucketDate: d, distance: km(v), time: mins(v * 2.85), routes: v > 0 ? Int(v / 18) + 1 : 0)
            }
            totalCurrentDistance  = currentPoints.reduce(0)  { $0 + $1.distance }
            totalCurrentTime      = currentPoints.reduce(0)  { $0 + $1.time }
            totalCurrentRoutes    = currentPoints.reduce(0)  { $0 + $1.routes }
            totalPreviousDistance = previousPoints.reduce(0) { $0 + $1.distance }
            totalPreviousTime     = previousPoints.reduce(0) { $0 + $1.time }
            totalPreviousRoutes   = previousPoints.reduce(0) { $0 + $1.routes }

        case .yearToDate:
            let slots = bucketDates(for: .yearToDate, isCurrent: true, calendar: cal)
            // Jan-May (5 months for 2026): realistic winter→spring ramp
            let ytdDist: [Double] = [120, 180, 240, 310, 280]
            let ytdTime: [Double] = [342, 514, 686, 886, 800]
            let ytdRoutes: [Int]  = [6,   9,   12,  16,  14]
            currentPoints = slots.enumerated().map { i, d in
                guard i < ytdDist.count else { return ChartDataPoint(bucketDate: d) }
                return ChartDataPoint(bucketDate: d, distance: km(ytdDist[i]), time: mins(ytdTime[i]), routes: ytdRoutes[i])
            }
            let prevSlots = bucketDates(for: .yearToDate, isCurrent: false, calendar: cal)
            let prevDist: [Double] = [95, 145, 210, 275, 250]
            let prevTime: [Double] = [271, 414, 600, 786, 714]
            let prevRoutes: [Int]  = [5,  7,   10,  14,  12]
            previousPoints = prevSlots.enumerated().map { i, d in
                guard i < prevDist.count else { return ChartDataPoint(bucketDate: d) }
                return ChartDataPoint(bucketDate: d, distance: km(prevDist[i]), time: mins(prevTime[i]), routes: prevRoutes[i])
            }
            totalCurrentDistance  = currentPoints.reduce(0)  { $0 + $1.distance }
            totalCurrentTime      = currentPoints.reduce(0)  { $0 + $1.time }
            totalCurrentRoutes    = currentPoints.reduce(0)  { $0 + $1.routes }
            totalPreviousDistance = previousPoints.reduce(0) { $0 + $1.distance }
            totalPreviousTime     = previousPoints.reduce(0) { $0 + $1.time }
            totalPreviousRoutes   = previousPoints.reduce(0) { $0 + $1.routes }

        case .oneYear:
            let slots = bucketDates(for: .oneYear, isCurrent: true, calendar: cal)
            // Seasonal pattern: summer peaks, winter low
            let yearDist:   [Double] = [95, 180, 260, 310, 340, 295, 280, 250, 200, 155, 120, 90]
            let yearTime:   [Double] = [271, 514, 743, 886, 971, 843, 800, 714, 571, 443, 343, 257]
            let yearRoutes: [Int]    = [5,   9,   13,  16,  17,  15,  14,  13,  10,  8,   6,   5]
            currentPoints = slots.enumerated().map { i, d in
                guard i < yearDist.count else { return ChartDataPoint(bucketDate: d) }
                return ChartDataPoint(bucketDate: d, distance: km(yearDist[i]), time: mins(yearTime[i]), routes: yearRoutes[i])
            }
            let prevSlots = bucketDates(for: .oneYear, isCurrent: false, calendar: cal)
            let prevDist:   [Double] = [80, 155, 225, 270, 295, 255, 240, 215, 170, 130, 100, 75]
            let prevTime:   [Double] = [229, 443, 643, 771, 843, 729, 686, 614, 486, 371, 286, 214]
            let prevRoutes: [Int]    = [4,   8,   11,  14,  15,  13,  12,  11,  9,   7,   5,   4]
            previousPoints = prevSlots.enumerated().map { i, d in
                guard i < prevDist.count else { return ChartDataPoint(bucketDate: d) }
                return ChartDataPoint(bucketDate: d, distance: km(prevDist[i]), time: mins(prevTime[i]), routes: prevRoutes[i])
            }
            totalCurrentDistance  = currentPoints.reduce(0)  { $0 + $1.distance }
            totalCurrentTime      = currentPoints.reduce(0)  { $0 + $1.time }
            totalCurrentRoutes    = currentPoints.reduce(0)  { $0 + $1.routes }
            totalPreviousDistance = previousPoints.reduce(0) { $0 + $1.distance }
            totalPreviousTime     = previousPoints.reduce(0) { $0 + $1.time }
            totalPreviousRoutes   = previousPoints.reduce(0) { $0 + $1.routes }
        }

        // Heatmap: 3-5 rides/week spread over the last year
        heatmapData = [:]
        heatmapDistanceData = [:]
        heatmapTimeData = [:]
        var seed = 42
        func nextBool(density: Int) -> Bool { seed = (seed * 1103515245 + 12345) & 0x7fffffff; return seed % density == 0 }
        for dayOffset in 0..<365 {
            let d = daysAgo(dayOffset)
            let count = nextBool(density: 3) ? 2 : (nextBool(density: 2) ? 1 : 0)
            if count > 0 {
                heatmapData[d] = count
                // ~15-35 km per ride, ~45-100 min per ride
                let distPerRide = 15_000.0 + Double((dayOffset * 17 + 3) % 20_000)
                let timePerRide = 45.0 * 60 + Double((dayOffset * 23 + 7) % 3300)
                heatmapDistanceData[d] = Double(count) * distPerRide
                heatmapTimeData[d] = Double(count) * timePerRide
            }
        }

        // Speed points: ~2-3 rides/week across the last year, gentle upward trend.
        // Generated for the full year then filtered to the selected period so the
        // period picker actually changes what appears in the chart.
        speedPoints = []
        for dayOffset in stride(from: 364, through: 0, by: -1) {
            let r = (dayOffset &* 1103515245 &+ 12345) & 0x7fff_ffff
            guard r % 3 != 0 else { continue }
            let fraction = Double(364 - dayOffset) / 364.0
            let baseKph  = 15.5 + fraction * 6.0
            let jitter   = Double((r % 300) - 150) / 100.0
            let kph      = max(13.0, baseKph + jitter)
            speedPoints.append(SpeedPoint(date: daysAgo(dayOffset), speed: kph / 3.6))
        }
        speedPoints.sort { $0.date < $1.date }

        let periodStart: Date
        switch period {
        case .oneWeek:     periodStart = daysAgo(6)
        case .oneMonth:    periodStart = daysAgo(29)
        case .threeMonths: periodStart = daysAgo(90)
        case .sixMonths:   periodStart = daysAgo(181)
        case .yearToDate:
            let year = cal.component(.year, from: today)
            var ytdC = DateComponents(); ytdC.year = year; ytdC.month = 1; ytdC.day = 1
            periodStart = cal.date(from: ytdC) ?? daysAgo(364)
        case .oneYear:     periodStart = daysAgo(364)
        }
        speedPoints = speedPoints.filter { $0.date >= periodStart }
    }
    #endif
}

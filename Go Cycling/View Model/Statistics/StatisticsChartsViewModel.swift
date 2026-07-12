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
    @Published var heatmapElevationData: [Date: Double] = [:]

    @Published var totalCurrentDistance: Double = 0
    @Published var totalCurrentTime: Double = 0
    @Published var totalCurrentRoutes: Int = 0
    @Published var totalCurrentElevationGain: Double = 0
    @Published var totalPreviousDistance: Double = 0
    @Published var totalPreviousTime: Double = 0
    @Published var totalPreviousRoutes: Int = 0
    @Published var totalPreviousElevationGain: Double = 0

    var distanceChangePct: Double {
        guard totalPreviousDistance > 0 else { return totalCurrentDistance > 0 ? 100 : 0 }
        return ((totalCurrentDistance - totalPreviousDistance) / totalPreviousDistance) * 100
    }

    var timeChangePct: Double {
        guard totalPreviousTime > 0 else { return totalCurrentTime > 0 ? 100 : 0 }
        return ((totalCurrentTime - totalPreviousTime) / totalPreviousTime) * 100
    }

    var elevationChangePct: Double {
        guard totalPreviousElevationGain > 0 else { return totalCurrentElevationGain > 0 ? 100 : 0 }
        return ((totalCurrentElevationGain - totalPreviousElevationGain) / totalPreviousElevationGain) * 100
    }

    var routeCountChange: Int { totalCurrentRoutes - totalPreviousRoutes }

    init(period: ChartPeriod) {
        loadData(for: period)
    }

    func loadData(for period: ChartPeriod) {
        var cal = Calendar.current
        cal.timeZone = .current

        let (currentRides, previousRides) = BikeRide.fetchRidesForPeriod(period, calendar: cal)

        currentPoints  = buildBuckets(rides: currentRides,  period: period, isCurrent: true,  calendar: cal)
        previousPoints = buildBuckets(rides: previousRides, period: period, isCurrent: false, calendar: cal)

        totalCurrentDistance      = currentRides.reduce(0)  { $0 + $1.cyclingDistance }
        totalCurrentTime          = currentRides.reduce(0)  { $0 + $1.cyclingTime }
        totalCurrentRoutes        = currentRides.count
        totalCurrentElevationGain = currentRides.reduce(0)  { $0 + MetricsFormatting.computeElevationGain(elevations: $1.cyclingElevations) }
        totalPreviousDistance      = previousRides.reduce(0) { $0 + $1.cyclingDistance }
        totalPreviousTime          = previousRides.reduce(0) { $0 + $1.cyclingTime }
        totalPreviousRoutes        = previousRides.count
        totalPreviousElevationGain = previousRides.reduce(0) { $0 + MetricsFormatting.computeElevationGain(elevations: $1.cyclingElevations) }

        heatmapData = [:]
        heatmapDistanceData = [:]
        heatmapTimeData = [:]
        heatmapElevationData = [:]
        for ride in currentRides {
            let day = cal.startOfDay(for: ride.cyclingStartTime)
            heatmapData[day, default: 0] += 1
            heatmapDistanceData[day, default: 0] += ride.cyclingDistance
            heatmapTimeData[day, default: 0] += ride.cyclingTime
            heatmapElevationData[day, default: 0] += MetricsFormatting.computeElevationGain(elevations: ride.cyclingElevations)
        }
    }

    // MARK: - Bucketing

    private func buildBuckets(rides: [BikeRide], period: ChartPeriod, isCurrent: Bool, calendar: Calendar) -> [ChartDataPoint] {
        let slots = bucketDates(for: period, isCurrent: isCurrent, calendar: calendar)
        var map: [Date: ChartDataPoint] = Dictionary(
            uniqueKeysWithValues: slots.map { ($0, ChartDataPoint(bucketDate: $0)) }
        )
        for ride in rides {
            if let key = bucketKey(for: ride.cyclingStartTime, period: period, slots: slots, calendar: calendar) {
                map[key]?.distance      += ride.cyclingDistance
                map[key]?.time          += ride.cyclingTime
                map[key]?.routes        += 1
                map[key]?.elevationGain += MetricsFormatting.computeElevationGain(elevations: ride.cyclingElevations)
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
}

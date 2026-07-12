//
//  CyclingChartsView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-08-31.
//

import SwiftUI
import CoreData

// MARK: - Section container (shown inside StatisticsView's Form)

struct CyclingChartsView: View {
    var body: some View {
        Section(header: Text(RecordsFormatting.headerStrings[1]), footer: Text(RecordsFormatting.footerStrings[0])) {
            if #available(iOS 16, *) {
                NewChartRows()
            } else {
                LegacyChartRows()
            }
        }
    }
}

// MARK: - iOS 16+ rows

@available(iOS 16, *)
private struct NewChartRows: View {
    var body: some View {
        NavigationLink(destination: CyclingChartsDetailView()) {
            CyclingChartsMiniCard()
        }
        NavigationLink(destination: ActivityHeatmapDetailView()) {
            HeatmapMiniCard()
        }
    }
}

// MARK: - iOS 16+ mini cards

@available(iOS 16, *)
private struct CyclingChartsMiniCard: View {
    @AppStorage("lastChartPeriod") private var lastChartPeriodRaw: Int = ChartPeriod.oneWeek.rawValue
    @StateObject private var loader = ChartMiniCardLoader()
    @EnvironmentObject var preferences: Preferences

    var period: ChartPeriod { ChartPeriod(rawValue: lastChartPeriodRaw) ?? .oneWeek }

    var themeColor: Color {
        Color(UserPreferences.convertColourChoiceToUIColor(colour: preferences.colourChoiceConverted))
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Cycling Charts")
                    .font(.headline)
                    .foregroundColor(themeColor)
                Spacer()
                Text(period.label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(Color(.systemGray5)))
            }
            HStack {
                Text("Distance")
                Spacer()
                Text(MetricsFormatting.formatDistance(distance: loader.totalDistance, usingMetric: preferences.usingMetric))
                    .bold()
                Text(loader.changeString(for: loader.distanceChangePct))
                    .bold()
                    .foregroundColor(loader.distanceChangePct >= 0 ? .green : .red)
            }
            HStack {
                Text("Elevation")
                Spacer()
                Text(MetricsFormatting.formatElevationWithoutUnits(elevation: loader.totalElevationGain, usingMetric: preferences.usingMetric) + " " + MetricsFormatting.getElevationUnits(usingMetric: preferences.usingMetric))
                    .bold()
                Text(loader.changeString(for: loader.elevationChangePct))
                    .bold()
                    .foregroundColor(loader.elevationChangePct >= 0 ? .green : .red)
            }
            HStack {
                Text("Time")
                Spacer()
                Text(MetricsFormatting.formatTime(time: loader.totalTime))
                    .bold()
                Text(loader.changeString(for: loader.timeChangePct))
                    .bold()
                    .foregroundColor(loader.timeChangePct >= 0 ? .green : .red)
            }
            HStack {
                Text("Routes")
                Spacer()
                Text("\(loader.totalRoutes)")
                    .bold()
                Text(loader.changeString(for: loader.routesChangePct))
                    .bold()
                    .foregroundColor(loader.routesChangePct >= 0 ? .green : .red)
            }
        }
        .onAppear { loader.load(period: period) }
        .onChange(of: lastChartPeriodRaw) { _ in loader.load(period: period) }
    }
}

@available(iOS 16, *)
private class ChartMiniCardLoader: ObservableObject {
    @Published var totalDistance: Double = 0
    @Published var totalTime: Double = 0
    @Published var totalElevationGain: Double = 0
    @Published var distanceChangePct: Double = 0
    @Published var timeChangePct: Double = 0
    @Published var routesChangePct: Double = 0
    @Published var elevationChangePct: Double = 0
    @Published var totalRoutes: Int = 0

    func changeString(for pct: Double) -> String {
        let rounded = Int(round(pct))
        if rounded == 0 { return "0%" }
        let sym = rounded > 0 ? "↑" : "↓"
        let mag = abs(rounded) < 999 ? "\(abs(rounded))" : ">999"
        return "\(sym)\(mag)%"
    }

    func load(period: ChartPeriod) {
        let vm = StatisticsChartsViewModel(period: period)
        totalDistance      = vm.totalCurrentDistance
        totalTime          = vm.totalCurrentTime
        totalElevationGain = vm.totalCurrentElevationGain
        totalRoutes         = vm.totalCurrentRoutes
        distanceChangePct   = vm.distanceChangePct
        timeChangePct       = vm.timeChangePct
        elevationChangePct  = vm.elevationChangePct
        let prev = vm.totalPreviousRoutes
        routesChangePct = prev > 0
            ? Double(vm.totalCurrentRoutes - prev) / Double(prev) * 100
            : (vm.totalCurrentRoutes > 0 ? 100 : 0)
    }
}

@available(iOS 16, *)
private struct HeatmapMiniCard: View {
    @StateObject private var loader = HeatmapMiniCardLoader()
    @EnvironmentObject var preferences: Preferences

    var themeColor: Color {
        Color(UserPreferences.convertColourChoiceToUIColor(colour: preferences.colourChoiceConverted))
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Activity Heatmap")
                    .font(.headline)
                    .foregroundColor(themeColor)
                Spacer()
            }
            HStack {
                Text("This year")
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(loader.yearlyRideCount) \(loader.yearlyRideCount == 1 ? "route" : "routes")")
                    .bold()
            }
        }
        .onAppear { loader.load() }
    }
}

@available(iOS 16, *)
private class HeatmapMiniCardLoader: ObservableObject {
    @Published var yearlyRideCount: Int = 0

    func load() {
        let vm = StatisticsChartsViewModel(period: .yearToDate)
        yearlyRideCount = vm.totalCurrentRoutes
    }
}

// MARK: - Legacy iOS 14/15 rows (unchanged from original CyclingChartsView logic)

private struct LegacyChartRows: View {
    var invalidData: Bool
    @FetchRequest var bikeRidesIn1Week: FetchedResults<BikeRide>
    @FetchRequest var bikeRidesIn1WeekBefore: FetchedResults<BikeRide>
    @FetchRequest var bikeRidesIn5Weeks: FetchedResults<BikeRide>
    @FetchRequest var bikeRidesIn5WeeksBefore: FetchedResults<BikeRide>
    @FetchRequest var bikeRidesIn26Weeks: FetchedResults<BikeRide>
    @FetchRequest var bikeRidesIn26WeeksBefore: FetchedResults<BikeRide>

    init() {
        self.invalidData = false

        let requests: [NSFetchRequest<BikeRide>?] = BikeRide.fetchRequestsWithDateRanges()
        let countNils = requests.filter({ $0 == nil }).count
        if countNils > 0 && requests.count == 6 {
            self.invalidData = true
            let request: NSFetchRequest<BikeRide> = BikeRide.fetchRequest()
            request.sortDescriptors = []
            self._bikeRidesIn1Week         = FetchRequest<BikeRide>(fetchRequest: request)
            self._bikeRidesIn1WeekBefore   = FetchRequest<BikeRide>(fetchRequest: request)
            self._bikeRidesIn5Weeks        = FetchRequest<BikeRide>(fetchRequest: request)
            self._bikeRidesIn5WeeksBefore  = FetchRequest<BikeRide>(fetchRequest: request)
            self._bikeRidesIn26Weeks       = FetchRequest<BikeRide>(fetchRequest: request)
            self._bikeRidesIn26WeeksBefore = FetchRequest<BikeRide>(fetchRequest: request)
        } else {
            self._bikeRidesIn1Week         = FetchRequest<BikeRide>(fetchRequest: requests[0]!)
            self._bikeRidesIn1WeekBefore   = FetchRequest<BikeRide>(fetchRequest: requests[1]!)
            self._bikeRidesIn5Weeks        = FetchRequest<BikeRide>(fetchRequest: requests[2]!)
            self._bikeRidesIn5WeeksBefore  = FetchRequest<BikeRide>(fetchRequest: requests[3]!)
            self._bikeRidesIn26Weeks       = FetchRequest<BikeRide>(fetchRequest: requests[4]!)
            self._bikeRidesIn26WeeksBefore = FetchRequest<BikeRide>(fetchRequest: requests[5]!)
        }
    }

    var body: some View {
        if !self.invalidData {
            ForEach(0..<3) { index in
                NavigationLink(destination: BarChartView(index: index)) {
                    SingleChartListCellView(
                        distances: getDistanceData(index: index),
                        times: getTimeData(index: index),
                        numberOfRoutes: getNumberOfRoutes(index: index),
                        index: index
                    )
                }
            }
        } else {
            Text("Unable to retrieve cycling data at this time.")
        }
    }

    func getDistanceData(index: Int) -> [Double] {
        var result: [Double] = [0.0, 0.0]
        switch index {
        case 0:
            for e in bikeRidesIn1WeekBefore { result[0] += e.cyclingDistance }
            for e in bikeRidesIn1Week       { result[1] += e.cyclingDistance }
        case 1:
            for e in bikeRidesIn5WeeksBefore { result[0] += e.cyclingDistance }
            for e in bikeRidesIn5Weeks        { result[1] += e.cyclingDistance }
        case 2:
            for e in bikeRidesIn26WeeksBefore { result[0] += e.cyclingDistance }
            for e in bikeRidesIn26Weeks        { result[1] += e.cyclingDistance }
        default: break
        }
        return result
    }

    func getTimeData(index: Int) -> [Double] {
        var result: [Double] = [0.0, 0.0]
        switch index {
        case 0:
            for e in bikeRidesIn1WeekBefore { result[0] += e.cyclingTime }
            for e in bikeRidesIn1Week       { result[1] += e.cyclingTime }
        case 1:
            for e in bikeRidesIn5WeeksBefore { result[0] += e.cyclingTime }
            for e in bikeRidesIn5Weeks        { result[1] += e.cyclingTime }
        case 2:
            for e in bikeRidesIn26WeeksBefore { result[0] += e.cyclingTime }
            for e in bikeRidesIn26Weeks        { result[1] += e.cyclingTime }
        default: break
        }
        return result
    }

    func getNumberOfRoutes(index: Int) -> [Int] {
        switch index {
        case 0: return [bikeRidesIn1WeekBefore.count,   bikeRidesIn1Week.count]
        case 1: return [bikeRidesIn5WeeksBefore.count,  bikeRidesIn5Weeks.count]
        case 2: return [bikeRidesIn26WeeksBefore.count, bikeRidesIn26Weeks.count]
        default: return [0, 0]
        }
    }
}

//
//  ChartPeriod.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2026-05-23.
//

import Foundation

enum ChartPeriod: Int, CaseIterable, Identifiable {
    case oneWeek = 0
    case oneMonth
    case threeMonths
    case sixMonths
    case yearToDate
    case oneYear

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .oneWeek:     return "1W"
        case .oneMonth:    return "1M"
        case .threeMonths: return "3M"
        case .sixMonths:   return "6M"
        case .yearToDate:  return "YTD"
        case .oneYear:     return "1Y"
        }
    }

    var displayName: String {
        switch self {
        case .oneWeek:     return "Past 7 Days"
        case .oneMonth:    return "Past Month"
        case .threeMonths: return "Past 3 Months"
        case .sixMonths:   return "Past 6 Months"
        case .yearToDate:  return "Year to Date"
        case .oneYear:     return "Past Year"
        }
    }

    var bucketComponent: Calendar.Component {
        switch self {
        case .oneWeek, .oneMonth:      return .day
        case .threeMonths, .sixMonths: return .weekOfYear
        case .yearToDate, .oneYear:    return .month
        }
    }

    func formatXLabel(_ date: Date) -> String {
        let f = DateFormatter()
        switch self {
        case .oneWeek:
            f.dateFormat = "EEE"
        case .oneMonth:
            f.dateFormat = "d"
        case .threeMonths, .sixMonths:
            f.dateFormat = "MMM d"
        case .yearToDate, .oneYear:
            f.dateFormat = "MMM"
        }
        return f.string(from: date)
    }
}

// Metrics displayed in the bar chart
enum ChartMetric: Int, CaseIterable, Identifiable {
    case distance = 0
    case time
    case routes

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .distance: return "Distance"
        case .time:     return "Time"
        case .routes:   return "Routes"
        }
    }
}

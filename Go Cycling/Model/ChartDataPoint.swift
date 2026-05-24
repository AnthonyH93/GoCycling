//
//  ChartDataPoint.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2026-05-23.
//

import Foundation

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let bucketDate: Date
    var distance: Double = 0   // meters
    var time: Double = 0       // seconds
    var routes: Int = 0

    func value(for metric: ChartMetric) -> Double {
        switch metric {
        case .distance: return distance
        case .time:     return time
        case .routes:   return Double(routes)
        }
    }
}

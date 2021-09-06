//
//  CyclingChartsViewModel.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-09-02.
//

import Foundation
import SwiftUI

// Contains all of the data to be used to construct the statistics charts
class CyclingChartsViewModel: ObservableObject {
    static let titleStrings: [String] = ["Activity in the past 7 days",
                                         "Activity in the past 5 weeks",
                                         "Activity in the past 26 weeks"]
    
    @Published var pastWeekData: [BikeRide] = BikeRide.bikeRidesInPastWeek() {
        willSet {
            self.setPastWeekFormattedData()
        }
    }
    @Published var past5WeeksData: [BikeRide] = BikeRide.bikeRidesInPast5Weeks()
    @Published var past26WeeksData: [BikeRide] = BikeRide.bikeRidesInPast26Weeks()
    
    @Published var pastWeekDistances: [Double] = [Double].init(repeating: 0.0, count: 7)
    @Published var pastWeekDistancesNormalized: [Double] = [Double].init(repeating: 0.0, count: 7)
    
    init() {
        self.setPastWeekFormattedData()
    }
    
    func setPastWeekFormattedData() {
        // Reset current values
        self.pastWeekDistances = [Double].init(repeating: 0.0, count: 7)
        self.pastWeekDistancesNormalized = [Double].init(repeating: 0.0, count: 7)
        
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        let startOfToday = calendar.startOfDay(for: Date())
        let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday)
        
        if let date = endOfToday {
            for entry in pastWeekData {
                let dateDiff = entry.cyclingStartTime.fullDistance(from: date, resultIn: .day, calendar: calendar) ?? 0
                print("Distance : \(entry.cyclingDistance), Date: \(dateDiff)")
                if (dateDiff < 7 && dateDiff >= 0) {
                    self.pastWeekDistances[6 - dateDiff] += entry.cyclingDistance
                }
            }
        }
        
        // Next, set the normalized values
        let maxDistance = pastWeekDistances.max() ?? 1
        if (maxDistance > 0) {
            for index in 0..<pastWeekDistancesNormalized.count {
                pastWeekDistancesNormalized[index] = pastWeekDistances[index]/maxDistance
            }
        }
    }
    
}

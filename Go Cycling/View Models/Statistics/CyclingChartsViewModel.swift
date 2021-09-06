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
    static let titleStrings: [String] = ["Activity in the Past 7 Days",
                                         "Activity in the Past 5 Weeks",
                                         "Activity in the Past 26 Weeks"]
    
    @Published var pastWeekData: [BikeRide] = BikeRide.bikeRidesInPastWeek()
    @Published var past5WeeksData: [BikeRide] = BikeRide.bikeRidesInPast5Weeks()
    @Published var past26WeeksData: [BikeRide] = BikeRide.bikeRidesInPast26Weeks()
    
    @Published var pastData: [[Double]] = [[Double].init(repeating: 0.0, count: 7), [Double].init(repeating: 0.0, count: 5), [Double].init(repeating: 0.0, count: 26)]
    @Published var pastDataNormalized: [[Double]] = [[Double].init(repeating: 0.0, count: 7), [Double].init(repeating: 0.0, count: 5), [Double].init(repeating: 0.0, count: 26)]
    
    init() {
        self.setPastWeekFormattedData()
        self.setPast5WeeksFormattedData()
        self.setPast26WeeksFormattedData()
    }
    
    // Below are 3 functions to setup the arrays of data for the charts on the statistics tab
    func setPastWeekFormattedData() {
        // Reset current values - 7 entries (one for each day)
        self.pastData[0] = [Double].init(repeating: 0.0, count: 7)
        self.pastDataNormalized[0] = [Double].init(repeating: 0.0, count: 7)
        
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        let startOfToday = calendar.startOfDay(for: Date())
        let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday)
        
        if let date = endOfToday {
            for entry in pastWeekData {
                let dateDiff = entry.cyclingStartTime.fullDistance(from: date, resultIn: .day, calendar: calendar) ?? 0
                if (dateDiff < 7 && dateDiff >= 0) {
                    self.pastData[0][6 - dateDiff] += entry.cyclingDistance
                }
            }
        }
        
        // Next, set the normalized values
        let maxDistance = pastData[0].max() ?? 1
        if (maxDistance > 0) {
            for index in 0..<pastDataNormalized[0].count {
                pastDataNormalized[0][index] = pastData[0][index]/maxDistance
            }
        }
    }
    
    func setPast5WeeksFormattedData() {
        // Reset current values - 5 values (1 for each week)
        self.pastData[1] = [Double].init(repeating: 0.0, count: 5)
        self.pastDataNormalized[1] = [Double].init(repeating: 0.0, count: 5)
        
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        let startOfToday = calendar.startOfDay(for: Date())
        let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday)
        
        if let date = endOfToday {
            for entry in past5WeeksData {
                let dateDiff = entry.cyclingStartTime.fullDistance(from: date, resultIn: .day, calendar: calendar) ?? 0
                if (dateDiff < 35 && dateDiff >= 0) {
                    self.pastData[1][4 - (dateDiff / 7)] += entry.cyclingDistance
                }
            }
        }
        
        // Next, set the normalized values
        let maxDistance = pastData[1].max() ?? 1
        if (maxDistance > 0) {
            for index in 0..<pastDataNormalized[1].count {
                pastDataNormalized[1][index] = pastData[1][index]/maxDistance
            }
        }
    }
    
    func setPast26WeeksFormattedData() {
        // Reset current values - 26 days (1 for each week)
        self.pastData[2] = [Double].init(repeating: 0.0, count: 26)
        self.pastDataNormalized[2] = [Double].init(repeating: 0.0, count: 26)
        
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        let startOfToday = calendar.startOfDay(for: Date())
        let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday)
        
        if let date = endOfToday {
            for entry in past26WeeksData {
                let dateDiff = entry.cyclingStartTime.fullDistance(from: date, resultIn: .day, calendar: calendar) ?? 0
                if (dateDiff < 182 && dateDiff >= 0) {
                    self.pastData[2][25 - (dateDiff / 7)] += entry.cyclingDistance
                }
            }
        }
        
        // Next, set the normalized values
        let maxDistance = pastData[2].max() ?? 1
        if (maxDistance > 0) {
            for index in 0..<pastDataNormalized[2].count {
                pastDataNormalized[2][index] = pastData[2][index]/maxDistance
            }
        }
    }
    
    // Get a string to display the date range being shown
    func getDateRange(index: Int) -> String {
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        let startOfToday = calendar.startOfDay(for: Date())
        
        var daysBack = 0
        if (index == 0) {
            daysBack = -6
        }
        else if (index == 1) {
            daysBack = -34
        }
        else {
            daysBack = -181
        }
        
        let dateFrom = calendar.date(byAdding: .day, value: daysBack, to: startOfToday)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        return "\(dateFormatter.string(from: dateFrom ?? startOfToday)) - \(dateFormatter.string(from: startOfToday))"
    }
}

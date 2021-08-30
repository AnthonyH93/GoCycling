//
//  RecordsFormatting.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-08-30.
//

import Foundation

// Class to format record strings
class RecordsFormatting {
    static func formatOptionalDate(date: Date?) -> String? {
        if let dateValue = date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM dd, yyyy"
            return(dateFormatter.string(from: dateValue))
        }
        else {
            return nil
        }
    }
    
    // Array of record strings to be used on the statistics tab
    static let recordsStrings = ["Total Distance Cycled",
                                 "Total Cycling Time",
                                 "Total Saved Cycling Routes",
                                 "Longest Distance in a Single Route",
                                 "Longest Time Cycled in a Single Route"]
    
    static func getFastestAvgSpeedString(usingMetric: Bool) -> String {
        let distanceString = usingMetric ? "1 km" : "0.62 mi"
        return "Best Average Cycling Speed for a Route Longer than \(distanceString)"
    }
}

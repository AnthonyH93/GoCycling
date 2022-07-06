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
                                 "Longest Distance Cycled",
                                 "Longest Cycling Time",
                                 "Best Average Cycling Speed"]
    
    // Header and footer strings for the vrious sections of the statistics tab form
    static let headerStrings = ["Cycling Records",
                                "Cycling Charts",
                                "Activity Awards"]
    
    static let footerStrings = ["Click on a row above to view a detailed chart of that activity period. Percentage changes compare the current activity period to the previous one. This data is based on the currently saved cycling routes.",
                                "Progress toward unlocking exclusive alternate app icons. Unlocked icons will not be lost when routes are deleted or statistics are reset."]
    
    // Text to mention that only routes longer than 1 KM are counted towards best average speed
    static func getCyclingRecordsFooterText(usingMetric: Bool) -> String {
        let distanceString = usingMetric ? "1 km" : "0.62 mi"
        return "Only routes longer than \(distanceString) are counted for the best average cycling speed record."
    }
}

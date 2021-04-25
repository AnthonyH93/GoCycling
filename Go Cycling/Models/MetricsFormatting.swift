//
//  MetricsFormatting.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-24.
//

import Foundation
import CoreLocation

class MetricsFormatting {
    static func formatDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        return(dateFormatter.string(from: date))
    }
    
    static func formatDistance(distance: CLLocationDistance, usingMetric: Bool) -> String {
        let distanceKilometres = round(100 * distance/1000)/100
        let distanceMiles = round(100 * (0.621371 * distance/1000))/100
        let distanceUnits = usingMetric ? "km" : "mi"
        let distanceString = "\(usingMetric ? distanceKilometres : distanceMiles) " + distanceUnits
        return distanceString
    }
    
    static func formatTime(time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    static func formatSpeed(distance: CLLocationDistance, time: TimeInterval, usingMetric: Bool) -> String {
        let speedUnits = usingMetric ? "km/h" : "mph"
        if (time == 0) {
            return "0 " + speedUnits
        }
        let speedMetresPerSecond = distance/time
        let speedKMH = round(100 * (3.6 * speedMetresPerSecond))/100
        let speedMPH = round(100 * (2.23694 * speedMetresPerSecond))/100
        let speedString = "\(usingMetric ? speedKMH : speedMPH) " + speedUnits
        return speedString
    }
    
    static func formatElevation(elevations: [CLLocationDistance], usingMetric: Bool) -> String {
        var elevationGain: CLLocationDistance = 0.0
        let elevationUnits = usingMetric ? "m" : "ft"
        
        for index in 0..<elevations.count {
            if (index > 0) {
                if (elevations[index] > elevations[index-1]) {
                    elevationGain += elevations[index] - elevations[index-1]
                }
            }
        }
        
        let elevationMetres = round(100 * elevationGain)/100
        let elevationFeet = round(100 * (3.28084 * elevationGain))/100
        let elevationString = "\(usingMetric ? elevationMetres : elevationFeet)" + elevationUnits
        return elevationString
    }
    
    static func formatTopSpeed(speeds: [CLLocationSpeed], usingMetric: Bool) -> String {
        var topSpeed: CLLocationSpeed = 0.0
        for speed in speeds {
            if (speed > topSpeed) {
                topSpeed = speed
            }
        }
        
        let speedUnits = usingMetric ? "km/h" : "mph"
        let speedKMH = round(100 * (3.6 * topSpeed))/100
        let speedMPH = round(100 * (2.23694 * topSpeed))/100
        let speedString = "\(usingMetric ? speedKMH : speedMPH) " + speedUnits
        return speedString
    }
}

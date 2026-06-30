//
//  MetricsFormatting.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-24.
//

import Foundation
import CoreLocation

// Class to format metrics throughout the history and cycle tabs
class MetricsFormatting {
    static func formatDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        return(dateFormatter.string(from: date))
    }
    
    static func formatStartTime(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }

    static func formatDateAndTime(date: Date) -> String {
        "\(formatDate(date: date)) · \(formatStartTime(date: date))"
    }
    
    static func formatDistance(distance: CLLocationDistance, usingMetric: Bool) -> String {
        let distanceKilometres = round(100 * distance/1000)/100
        let distanceMiles = round(100 * (0.621371 * distance/1000))/100
        let distanceUnits = usingMetric ? "km" : "mi"
        let distanceString = "\(usingMetric ? distanceKilometres : distanceMiles) " + distanceUnits
        return distanceString
    }
    
    static func formatTime(time: TimeInterval) -> String {
        var timeString = ""
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        
        if (hours > 0) {
            timeString = "\(hours)h"
        }
        if (minutes > 0) {
            timeString = timeString + " \(minutes)m"
        }
        if (seconds > 0 || timeString == "") {
            timeString = timeString + " \(seconds)s"
        }
        return timeString
    }
    
    static func formatAverageSpeed(speeds: [CLLocationSpeed], distance: CLLocationDistance, time: TimeInterval, usingMetric: Bool) -> String {
        let speedUnits = usingMetric ? "km/h" : "mph"
        if (time == 0) {
            return "0 " + speedUnits
        }
        
        // Check the top speed to ensure that the average speed never exceeds the top speed
        var topSpeed: CLLocationSpeed = 0.0
        var speedSum: CLLocationSpeed = 0.0
        for speed in speeds {
            if (speed > topSpeed) {
                topSpeed = speed
            }
            speedSum += speed < 0 ? 0 : speed
        }
        
        // Blind calculation of average speed based on distance and time, only valid if less than top speed
        var speedMetresPerSecond = distance/time
        speedMetresPerSecond = (topSpeed < speedMetresPerSecond) ? speedSum/Double(speeds.count) : speedMetresPerSecond
        
        let speedKMH = round(100 * (3.6 * speedMetresPerSecond))/100
        let speedMPH = round(100 * (2.23694 * speedMetresPerSecond))/100
        let speedString = "\(usingMetric ? speedKMH : speedMPH) " + speedUnits
        return speedString
    }
    
    // Peak-and-valley hysteresis: commits a climb only after a confirmed descent of > threshold
    // from the peak. This avoids the dead-zone bug of the prior baseline-reset approach, which
    // missed the trailing portion of climbs that didn't clear a fresh threshold from the peak.
    static func computeElevationGain(elevations: [CLLocationDistance]) -> CLLocationDistance {
        guard elevations.count >= 2 else { return 0.0 }
        let threshold: CLLocationDistance = 3.0
        var localMin = elevations[0]
        var localMax = elevations[0]
        var gain: CLLocationDistance = 0.0

        for elevation in elevations {
            if elevation > localMax {
                localMax = elevation
            } else if elevation < localMax - threshold {
                gain += localMax - localMin
                localMin = elevation
                localMax = elevation
            }
        }
        if localMax - localMin > threshold {
            gain += localMax - localMin
        }
        return gain
    }

    static func formatElevation(elevations: [CLLocationDistance], usingMetric: Bool) -> String {
        let elevationGain = computeElevationGain(elevations: elevations)
        let elevationUnits = usingMetric ? "m" : "ft"
        let elevationMetres = round(100 * elevationGain)/100
        let elevationFeet = round(100 * (3.28084 * elevationGain))/100
        return "\(usingMetric ? elevationMetres : elevationFeet) " + elevationUnits
    }

    static func formatElevationGainWithoutUnits(elevations: [CLLocationDistance], usingMetric: Bool) -> String {
        let gain = computeElevationGain(elevations: elevations)
        let elevationMetres = round(100 * gain) / 100
        let elevationFeet = round(100 * (3.28084 * gain)) / 100
        return "\(usingMetric ? elevationMetres : elevationFeet)"
    }

    static func formatMaxElevation(elevations: [CLLocationDistance], usingMetric: Bool) -> String {
        guard let maxElevation = elevations.max() else {
            return usingMetric ? "0 m" : "0 ft"
        }
        let elevationUnits = usingMetric ? "m" : "ft"
        let elevationMetres = round(100 * maxElevation) / 100
        let elevationFeet = round(100 * (3.28084 * maxElevation)) / 100
        return "\(usingMetric ? elevationMetres : elevationFeet) " + elevationUnits
    }
    
    static func formatTopSpeed(speeds: [CLLocationSpeed], usingMetric: Bool) -> String {
        let topSpeed = speeds.max() ?? 0.0
        
        let speedUnits = usingMetric ? "km/h" : "mph"
        let speedKMH = round(100 * (3.6 * topSpeed))/100
        let speedMPH = round(100 * (2.23694 * topSpeed))/100
        let speedString = "\(usingMetric ? speedKMH : speedMPH) " + speedUnits
        return speedString
    }
    
    // Used in the statistics tab for the average speed record
    static func formatSingleSpeed(speed: CLLocationSpeed, usingMetric: Bool) -> String {
        let speedUnits = usingMetric ? "km/h" : "mph"
        let speedKMH = round(100 * (3.6 * speed))/100
        let speedMPH = round(100 * (2.23694 * speed))/100
        let speedString = "\(usingMetric ? speedKMH : speedMPH) " + speedUnits
        return speedString
    }
    
    static func formatDistanceWithoutUnits(distance: CLLocationDistance, usingMetric: Bool) -> String {
        let distanceKilometres = round(100 * distance/1000)/100
        let distanceMiles = round(100 * (0.621371 * distance/1000))/100
        let distanceString = "\(usingMetric ? distanceKilometres : distanceMiles)"
        return distanceString
    }
    
    static func getDistanceUnits(usingMetric: Bool) -> String {
        return usingMetric ? "km" : "mi"
    }
    
    static func formatSpeedWithoutUnits(speed: CLLocationSpeed, usingMetric: Bool) -> String {
        if (speed < 0) {
            return "0.0"
        }
        let speedKMH = round(100 * (3.6 * speed))/100
        let speedMPH = round(100 * (2.23694 * speed))/100
        let speedString = "\(usingMetric ? speedKMH : speedMPH)"
        return speedString
    }
    
    static func getSpeedUnits(usingMetric: Bool) -> String {
        return usingMetric ? "km/h" : "mph"
    }
    
    static func formatElevationWithoutUnits(elevation: CLLocationDistance, usingMetric: Bool) -> String {
        let elevationMetres = round(100 * elevation)/100
        let elevationFeet = round(100 * (3.28084 * elevation))/100
        let elevationString = "\(usingMetric ? elevationMetres : elevationFeet)"
        return elevationString
    }
    
    static func getElevationUnits(usingMetric: Bool) -> String {
        return usingMetric ? "m" : "ft"
    }
}

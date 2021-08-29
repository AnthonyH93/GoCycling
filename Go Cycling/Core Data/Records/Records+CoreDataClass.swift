//
//  Records+CoreDataClass.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-08-29.
//
//

import Foundation
import CoreData

@objc(Records)
public class Records: NSManagedObject {
    // Determines unlocked icons bool array based on class members
    func setUnlockedIcons() {
        for index in 0..<self.unlockedIcons.count {
            // Leave as true if already set
            if self.unlockedIcons[index] == true {
                continue
            }
            else {
                // Indexes 0-2 are for individual ride distance records
                switch index {
                case 0:
                    if (self.longestCyclingDistance >= 10 * 1000) {
                        self.unlockedIcons[index] = true
                    }
                case 1:
                    if (self.longestCyclingDistance >= 25 * 1000) {
                        self.unlockedIcons[index] = true
                    }
                case 2:
                    if (self.longestCyclingDistance >= 50 * 1000) {
                        self.unlockedIcons[index] = true
                    }
                // Indexes 3-5 are for total distance records
                case 3:
                    if (self.totalCyclingDistance >= 100 * 1000) {
                        self.unlockedIcons[index] = true
                    }
                case 4:
                    if (self.totalCyclingDistance >= 250 * 1000) {
                        self.unlockedIcons[index] = true
                    }
                case 5:
                    if (self.totalCyclingDistance >= 500 * 1000) {
                        self.unlockedIcons[index] = true
                    }
                default:
                    fatalError("Index out of range")
                }
            }
        }
    }
    
    // Function to calculate the default values for the records object (if bike rides have been recorded) - returns a tuple corresponding to the records values
    static func getDefaultRecordsValues(bikeRides: [BikeRide]) -> (totalDistance: Double, totalTime: Double, totalRoutes: Int64, unlockedIcons: [Bool], longestDistance: Double, longestTime: Double, fastestAvgSpeed: Double, longestDistanceDate: Date?, longestTimeDate: Date?, fastestAvgSpeedDate: Date?) {
        // Calculate all values based on the bikeRides array
        var totalDistance: Double = 0.0
        var totalTime: Double = 0.0
        var bestAvgSpeed: Double = 0.0
        var bestAvgSpeedDate: Date? = nil
        
        let totalRoutes: Int64 = Int64(bikeRides.count)
        let unlockedIcons = [Bool](repeating: false, count: 6)
        let longestDistanceRide: BikeRide? = bikeRides.max{ $0.cyclingDistance < $1.cyclingDistance }
        let longestTimeRide: BikeRide? = bikeRides.max{ $0.cyclingTime < $1.cyclingTime }
        let maxDistance: Double = longestDistanceRide?.cyclingDistance ?? 0.0
        let maxDistanceDate: Date? = longestDistanceRide?.cyclingStartTime
        let maxTime: Double = longestTimeRide?.cyclingTime ?? 0.0
        let maxTimeDate: Date? = longestTimeRide?.cyclingStartTime
        
        
        for ride in bikeRides {
            // Routes longer than 1 KM can count for the best average speed
            if (ride.cyclingDistance > 999) {
                let maxSpeed = ride.cyclingSpeeds.max()
                let avgSpeed = ride.cyclingDistance/ride.cyclingTime
                // Must have a valid average speed
                if (maxSpeed ?? 0.0 >= avgSpeed && avgSpeed > bestAvgSpeed) {
                    bestAvgSpeed = avgSpeed
                    bestAvgSpeedDate = ride.cyclingStartTime
                }
            }
            // Sum distance and cycling time
            totalDistance += ride.cyclingDistance
            totalTime += ride.cyclingTime
        }
        return (totalDistance: totalDistance, totalTime: totalTime, totalRoutes: totalRoutes, unlockedIcons: unlockedIcons, longestDistance: maxDistance, longestTime: maxTime, fastestAvgSpeed: bestAvgSpeed, longestDistanceDate: maxDistanceDate, longestTimeDate: maxTimeDate, fastestAvgSpeedDate: bestAvgSpeedDate)
    }
    
    // Function to be called after a new cycling route to determine if record(s) have been broken - returns a tuple of the newly updated values
    static func getBrokenRecords(existingRecords: Records, speeds: [CLLocationSpeed?], distance: Double, startTime: Date, time: Double) -> (totalDistance: Double, totalTime: Double, totalRoutes: Int64, unlockedIcons: [Bool], longestDistance: Double, longestTime: Double, fastestAvgSpeed: Double, longestDistanceDate: Date?, longestTimeDate: Date?, fastestAvgSpeedDate: Date?) {
        
        let totalDistance: Double = existingRecords.totalCyclingDistance + distance
        let totalTime: Double = existingRecords.totalCyclingTime + time
        let totalRoutes: Int64 = existingRecords.totalCyclingRoutes + 1
        let maxDistance: Double = max(distance, existingRecords.longestCyclingDistance)
        let maxDistanceDate: Date? = distance > existingRecords.longestCyclingDistance ? startTime : existingRecords.longestCyclingDistanceDate
        let maxTime: Double = max(time, existingRecords.longestCyclingTime)
        let maxTimeDate: Date? = time > existingRecords.longestCyclingTime ? startTime : existingRecords.longestCyclingTimeDate
        
        var bestAvgSpeed: Double = existingRecords.fastestAverageSpeed
        var bestAvgSpeedDate: Date? = existingRecords.fastestAverageSpeedDate
        let speedsValidated = speeds.compactMap { $0 }
        // Only count fastest average speed if route was 1 KM or longer
        if (speedsValidated.count > 0 && distance > 999) {
            let maxSpeed = speedsValidated.max()
            let avgSpeed = distance/time
            // Must be a valid average speed
            if (maxSpeed ?? 0.0 >= avgSpeed && avgSpeed > existingRecords.fastestAverageSpeed) {
                bestAvgSpeed = avgSpeed
                bestAvgSpeedDate = startTime
            }
        }
        
        return (totalDistance: totalDistance, totalTime: totalTime, totalRoutes: totalRoutes, unlockedIcons: existingRecords.unlockedIcons, longestDistance: maxDistance, longestTime: maxTime, fastestAvgSpeed: bestAvgSpeed, longestDistanceDate: maxDistanceDate, longestTimeDate: maxTimeDate, fastestAvgSpeedDate: bestAvgSpeedDate)
    }
}

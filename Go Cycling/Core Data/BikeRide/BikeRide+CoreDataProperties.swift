//
//  BikeRide+CoreDataProperties.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-22.
//
//

import Foundation
import CoreData
import CoreLocation

extension BikeRide {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BikeRide> {
        return NSFetchRequest<BikeRide>(entityName: "BikeRide")
    }

    @NSManaged public var cyclingLatitudes: [CLLocationDegrees]
    @NSManaged public var cyclingLongitudes: [CLLocationDegrees]
    @NSManaged public var cyclingSpeeds: [CLLocationSpeed]
    @NSManaged public var cyclingElevations: [CLLocationDistance]
    @NSManaged public var cyclingDistance: Double
    @NSManaged public var cyclingStartTime: Date
    @NSManaged public var cyclingTime: Double
    @NSManaged public var cyclingRouteName: String

    static func sortByDistance(list: [BikeRide], ascending: Bool) -> [BikeRide] {
        var returnList: [BikeRide] = list
        for i in 0..<returnList.count {
            var current = i
            for j in i..<returnList.count {
                if (ascending && returnList[j].cyclingDistance < returnList[current].cyclingDistance) {
                    current = j
                }
                else if (!ascending && returnList[j].cyclingDistance > returnList[current].cyclingDistance) {
                    current = j
                }
                else {
                    // continue
                }
            }
            let temp: BikeRide = returnList[current]
            returnList[current] = returnList[i]
            returnList[i] = temp
        }
        return returnList
    }
    
    static func sortByDate(list: [BikeRide], ascending: Bool) -> [BikeRide] {
        var returnList: [BikeRide] = []

        let bikeRideDates: [Date] = list.map { $0.cyclingStartTime }

        let bikeRideDateTuples = zip(list, bikeRideDates)
        
        if (ascending) {
            returnList = bikeRideDateTuples.sorted { $0.1 < $1.1 }
                .map {$0.0}
        }
        else {
            returnList = bikeRideDateTuples.sorted { $0.1 > $1.1 }
                .map {$0.0}
        }
        return returnList
    }
    
    static func sortByTime(list: [BikeRide], ascending: Bool) -> [BikeRide] {
        var returnList: [BikeRide] = list
        for i in 0..<returnList.count {
            var current = i
            for j in i..<returnList.count {
                if (ascending && returnList[j].cyclingTime < returnList[current].cyclingTime) {
                    current = j
                }
                else if (!ascending && returnList[j].cyclingTime > returnList[current].cyclingTime) {
                    current = j
                }
                else {
                    // continue
                }
            }
            let temp: BikeRide = returnList[current]
            returnList[current] = returnList[i]
            returnList[i] = temp
        }
        return returnList
    }
}

extension BikeRide : Identifiable {
    static var savedBikeRidesFetchRequest: NSFetchRequest<BikeRide> {
        let request: NSFetchRequest<BikeRide> = BikeRide.fetchRequest()
        request.sortDescriptors = []

        return request
      }
}

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

    static func sortByDistance(list: [BikeRide]) -> [BikeRide] {
        var returnList: [BikeRide] = list
        for i in 0..<returnList.count {
            var max = i
            for j in i..<returnList.count {
                if returnList[j].cyclingDistance > returnList[max].cyclingDistance {
                    max = j
                }
            }
            let temp: BikeRide = returnList[max]
            returnList[max] = returnList[i]
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

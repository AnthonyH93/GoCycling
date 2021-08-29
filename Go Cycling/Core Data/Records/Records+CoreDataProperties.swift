//
//  Records+CoreDataProperties.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-08-29.
//
//

import Foundation
import CoreData


extension Records {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Records> {
        return NSFetchRequest<Records>(entityName: "Records")
    }

    @NSManaged public var totalCyclingTime: Double
    @NSManaged public var totalCyclingDistance: Double
    @NSManaged public var totalCyclingRoutes: Int64
    @NSManaged public var unlockedIcons: [Bool]
    @NSManaged public var longestCyclingDistance: Double
    @NSManaged public var longestCyclingTime: Double
    @NSManaged public var fastestAverageSpeed: Double
    @NSManaged public var fastestAverageSpeedDate: Date?
    @NSManaged public var longestCyclingDistanceDate: Date?
    @NSManaged public var longestCyclingTimeDate: Date?

}

extension Records : Identifiable {
    static var savedRecordsFetchRequest: NSFetchRequest<Records> {
        let request: NSFetchRequest<Records> = Records.fetchRequest()
        request.sortDescriptors = []

        return request
      }
}

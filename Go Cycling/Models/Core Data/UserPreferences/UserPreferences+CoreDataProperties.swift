//
//  SavedPreferences+CoreDataProperties.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-18.
//
//

import Foundation
import CoreData


extension UserPreferences {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserPreferences> {
        return NSFetchRequest<UserPreferences>(entityName: "UserPreferences")
    }

    @NSManaged public var usingMetric: Bool
    @NSManaged public var displayingMetrics: Bool
    @NSManaged public var colourChoice: String
    @NSManaged public var largeMetrics: Bool
        
    var colourChoiceConverted: ColourChoice {
        set {
            colourChoice = newValue.rawValue
        }
        get {
            ColourChoice(rawValue: colourChoice) ?? .blue
        }
    }

}

extension UserPreferences : Identifiable {
    static var savedPreferencesFetchRequest: NSFetchRequest<UserPreferences> {
        let request: NSFetchRequest<UserPreferences> = UserPreferences.fetchRequest()
        request.sortDescriptors = []

        return request
      }
}

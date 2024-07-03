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
    @NSManaged public var sortingChoice: String
    @NSManaged public var deletionConfirmation: Bool
    @NSManaged public var deletionEnabled: Bool
    @NSManaged public var iconIndex: Int
    @NSManaged public var namedRoutes: Bool
    @NSManaged public var selectedRoute: String
    @NSManaged public var autoLockDisabled: Bool
    @NSManaged public var healthSyncEnabled: Bool
        
    var colourChoiceConverted: ColourChoice {
        set {
            colourChoice = newValue.rawValue
        }
        get {
            ColourChoice(rawValue: colourChoice) ?? .blue
        }
    }
    
    var sortingChoiceConverted: SortChoice {
        set {
            sortingChoice = newValue.rawValue
        }
        get {
            SortChoice(rawValue: sortingChoice) ?? .dateDescending
        }
    }
    
    var metricsChoiceConverted: UnitsChoice {
        set {
            if (newValue.id == "metric") {
                usingMetric = true
            }
            else {
                usingMetric = false
            }
        }
        get {
            usingMetric ? .metric : .imperial
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

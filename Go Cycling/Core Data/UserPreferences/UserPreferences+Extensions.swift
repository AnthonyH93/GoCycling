//
//  UserPreferences+Extensions.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-05-01.
//

import Foundation
import CoreData

extension UserPreferences {
    static func storedSortingChoice() -> SortChoice {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<UserPreferences> = UserPreferences.fetchRequest()
        do {
            let items = try context.fetch(fetchRequest)
            return items[0].sortingChoiceConverted
        }
        catch let error as NSError {
            print("Error getting UserPreferences: \(error.localizedDescription), \(error.userInfo)")
        }
        return .dateDescending
    }
    
    static func storedSelectedRoute() -> String {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<UserPreferences> = UserPreferences.fetchRequest()
        do {
            let items = try context.fetch(fetchRequest)
            return (items[0].namedRoutes == true) ? items[0].selectedRoute : ""
        }
        catch let error as NSError {
            print("Error getting UserPreferences: \(error.localizedDescription), \(error.userInfo)")
        }
        return ""
    }
}

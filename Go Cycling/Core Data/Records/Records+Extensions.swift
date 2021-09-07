//
//  Records+Extensions.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-08-29.
//

import Foundation
import CoreData

extension Records {
    static func getStoredRecords() -> Records? {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<Records> = Records.fetchRequest()
        do {
            let items = try context.fetch(fetchRequest)
            return items[0]
        }
        catch let error as NSError {
            print("Error getting UserPreferences: \(error.localizedDescription), \(error.userInfo)")
        }
        return nil
    }

    static func getUnlockedIcons() -> [Bool] {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<Records> = Records.fetchRequest()
        do {
            let items = try context.fetch(fetchRequest)
            return items[0].unlockedIcons
        }
        catch let error as NSError {
            print("Error getting UserPreferences: \(error.localizedDescription), \(error.userInfo)")
        }
        return [Bool].init(repeating: false, count: 6)
    }
}

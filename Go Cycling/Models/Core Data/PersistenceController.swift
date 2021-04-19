//
//  PersistenceController.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-18.
//

import Foundation
import CoreData

struct PersistenceController {
    // A singleton for our entire app to use
    static let shared = PersistenceController()

    // Storage for Core Data
    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "GoCycling")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func save() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
                print("Preferences saved")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func storeUserPreferences(usingMetric: Bool, displayingMetrics: Bool, colourChoice: ColourChoice) {
        let context = container.viewContext
        
        let newPreferences = UserPreferences(context: context)
        newPreferences.usingMetric = usingMetric
        newPreferences.displayingMetrics = displayingMetrics
        newPreferences.colourChoice = colourChoice.rawValue
        
        do {
            try context.save()
            print("Preferences saved")
        } catch {
            print(error.localizedDescription)
        }
    }
}

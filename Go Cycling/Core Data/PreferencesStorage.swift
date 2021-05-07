//
//  PreferencesStorage.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-18.
//

import Foundation
import CoreData

class PreferencesStorage: NSObject, ObservableObject {
    @Published var storedPreferences: [UserPreferences] = []
    private let preferencesController: NSFetchedResultsController<UserPreferences>

    init(managedObjectContext: NSManagedObjectContext) {
        preferencesController = NSFetchedResultsController(fetchRequest: UserPreferences.savedPreferencesFetchRequest,
        managedObjectContext: managedObjectContext,
        sectionNameKeyPath: nil, cacheName: nil)

        super.init()

        preferencesController.delegate = self

        do {
            try preferencesController.performFetch()
            
            if (preferencesController.fetchedObjects?.count ?? 0 < 1) {
                // Default values for the user preferences
                let defaultPreferences = UserPreferences(context: managedObjectContext)
                defaultPreferences.usingMetric = true
                defaultPreferences.displayingMetrics = true
                defaultPreferences.largeMetrics = false
                defaultPreferences.colourChoice = ColourChoice.blue.rawValue
                defaultPreferences.sortingChoice = SortChoice.dateDescending.rawValue
                defaultPreferences.deletionConfirmation = true
                defaultPreferences.deletionEnabled = true
                defaultPreferences.iconIndex = 0
                storedPreferences = [defaultPreferences]
            }
            else {
                storedPreferences = preferencesController.fetchedObjects!
            }
        } catch {
            print("Failed to fetch items!")
        }
    }
}

extension PreferencesStorage: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let savedPreferences = controller.fetchedObjects as? [UserPreferences]
        else { return }

        storedPreferences = savedPreferences
    }
}

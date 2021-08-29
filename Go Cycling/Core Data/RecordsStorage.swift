//
//  RecordsStorage.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-08-29.
//

import Foundation
import CoreData

class RecordsStorage: NSObject, ObservableObject {
    @Published var storedRecords: [Records] = []
    private let recordsController: NSFetchedResultsController<Records>

    init(managedObjectContext: NSManagedObjectContext) {
        recordsController = NSFetchedResultsController(fetchRequest: Records.savedRecordsFetchRequest,
        managedObjectContext: managedObjectContext,
        sectionNameKeyPath: nil, cacheName: nil)

        super.init()

        recordsController.delegate = self

        do {
            try recordsController.performFetch()
            storedRecords = recordsController.fetchedObjects ?? []
        } catch {
            print("Failed to fetch items!")
        }
    }
}

extension RecordsStorage: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let savedRecords = controller.fetchedObjects as? [Records]
        else { return }

        storedRecords = savedRecords
    }
}

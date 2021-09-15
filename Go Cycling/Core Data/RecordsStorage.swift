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
    
    // Singleton instance
    static let shared: RecordsStorage = RecordsStorage()
    
    let persistenceController = PersistenceController.shared

    private override init() {
        recordsController = NSFetchedResultsController(fetchRequest: Records.savedRecordsFetchRequest,
                                                       managedObjectContext: PersistenceController.shared.container.viewContext,
                                                       sectionNameKeyPath: nil, cacheName: nil)

        super.init()

        recordsController.delegate = self

        do {
            try recordsController.performFetch()
            storedRecords = recordsController.fetchedObjects ?? []
            
            // Protection, since storedRecords should always have 1 item
            if (storedRecords.count == 0) {
                let bikeRides = BikeRide.allBikeRides()
                if (bikeRides.count > 0) {
                    let values = Records.getDefaultRecordsValues(bikeRides: bikeRides)
                    persistenceController.storeRecords(
                        totalDistance: values.totalDistance,
                        totalTime: values.totalTime,
                        totalRoutes: values.totalRoutes,
                        unlockedIcons: values.unlockedIcons,
                        longestDistance: values.longestDistance,
                        longestTime: values.longestTime,
                        fastestAvgSpeed: values.fastestAvgSpeed,
                        longestDistanceDate: values.longestDistanceDate,
                        longestTimeDate: values.longestTimeDate,
                        fastestAvgSpeedDate: values.fastestAvgSpeedDate)
                }
                else {
                    // Use default values if no routes are saved
                    persistenceController.storeRecords(
                        totalDistance: 0.0,
                        totalTime: 0.0,
                        totalRoutes: 0,
                        unlockedIcons: [Bool](repeating: false, count: 6),
                        longestDistance: 0.0,
                        longestTime: 0.0,
                        fastestAvgSpeed: 0.0,
                        longestDistanceDate: nil,
                        longestTimeDate: nil,
                        fastestAvgSpeedDate: nil)
                }
                
                let newRecords = Records.getStoredRecords()
                if let records = newRecords {
                    storedRecords.append(records)
                }
            }
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

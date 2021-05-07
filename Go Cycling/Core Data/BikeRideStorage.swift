//
//  BikeRideStorage.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-22.
//

import Foundation
import CoreData

class BikeRideStorage: NSObject, ObservableObject {
    @Published var storedBikeRides: [BikeRide] = []
    private let bikeRidesController: NSFetchedResultsController<BikeRide>

    init(managedObjectContext: NSManagedObjectContext) {
        bikeRidesController = NSFetchedResultsController(fetchRequest: BikeRide.savedBikeRidesFetchRequest,
        managedObjectContext: managedObjectContext,
        sectionNameKeyPath: nil, cacheName: nil)

        super.init()

        bikeRidesController.delegate = self

        do {
            try bikeRidesController.performFetch()
            storedBikeRides = bikeRidesController.fetchedObjects ?? []
        } catch {
            print("Failed to fetch items!")
        }
    }
}

extension BikeRideStorage: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let savedBikeRides = controller.fetchedObjects as? [BikeRide]
        else { return }

        storedBikeRides = savedBikeRides
    }
}


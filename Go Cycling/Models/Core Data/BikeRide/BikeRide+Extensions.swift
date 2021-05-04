//
//  BikeRide+Extensions.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-25.
//

import Foundation
import CoreData

extension BikeRide {
    
    static func allBikeRides() -> [BikeRide] {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<BikeRide> = BikeRide.fetchRequest()
        do {
            let items = try context.fetch(fetchRequest)
            return items
        }
        catch let error as NSError {
            print("Error getting BikeRides: \(error.localizedDescription), \(error.userInfo)")
        }
        return [BikeRide]()
    }
    
    static func allBikeRidesSorted() -> [BikeRide] {
        let bikeRidesUnsorted = allBikeRides()
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<UserPreferences> = UserPreferences.fetchRequest()
        do {
            let preferences = try context.fetch(fetchRequest)
            var bikeRides: [BikeRide] = []
            switch preferences[0].sortingChoiceConverted {
            case .distanceAscending:
                bikeRides = BikeRide.sortByDistance(list: bikeRidesUnsorted, ascending: true)
            case .distanceDescending:
                bikeRides = BikeRide.sortByDistance(list: bikeRidesUnsorted, ascending: false)
            case .dateAscending:
                bikeRides = BikeRide.sortByDate(list: bikeRidesUnsorted, ascending: true)
            case .dateDescending:
                bikeRides = BikeRide.sortByDate(list: bikeRidesUnsorted, ascending: false)
            case .timeAscending:
                bikeRides = BikeRide.sortByTime(list: bikeRidesUnsorted, ascending: true)
            case .timeDescending:
                bikeRides = BikeRide.sortByTime(list: bikeRidesUnsorted, ascending: false)
            }
            return bikeRides
        }
        catch let error as NSError {
            print("Error getting BikeRides: \(error.localizedDescription), \(error.userInfo)")
        }
        return [BikeRide]()
    }
}

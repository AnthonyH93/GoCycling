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
            var bikeRides: [BikeRide] = []
            switch Preferences.shared.sortingChoiceConverted {
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
    
    static func allRouteNames() -> [String] {
        let allBikeRides = allBikeRides()
        var uniqueNames: [String] = []

        for ride in allBikeRides {
            if (uniqueNames.firstIndex(of: ride.cyclingRouteName) == nil) {
                if (ride.cyclingRouteName != "Uncategorized") {
                    uniqueNames.append(ride.cyclingRouteName)
                }
            }
        }
        
        return uniqueNames.sorted { $0.lowercased() < $1.lowercased() }
    }
    
    static func allCategories() -> [Category] {
        let allBikeRides = allBikeRidesSorted()
        var categories: [Category] = []
        var names: [String] = []
        var numbers: [Int] = []
        var uncategorizedCounter = 0
        
        for ride in allBikeRides {
            if (names.firstIndex(of: ride.cyclingRouteName) == nil) {
                if (ride.cyclingRouteName != "Uncategorized") {
                    names.append(ride.cyclingRouteName)
                    numbers.append(1)
                }
                else {
                    uncategorizedCounter += 1
                }
            }
            else {
                numbers[names.firstIndex(of: ride.cyclingRouteName)!] += 1
            }
        }
        
        for (index, name) in names.enumerated() {
            categories.append(Category(name: name, number: numbers[index]))
        }
        
        // Sort the user created categories alphabeticaly
        categories = categories.sorted { $0.name.lowercased() < $1.name.lowercased() }
        
        if (uncategorizedCounter > 0) {
            categories.insert(Category(name: "Uncategorized", number: uncategorizedCounter), at: 0)
        }
        
        if (allBikeRides.count > 0) {
            categories.insert(Category(name: "All", number: allBikeRides.count), at: 0)
        }
        
        return categories
    }
    
    // Functions to get data for the charts on the statistics tab
    static func bikeRidesInPastWeek() -> [BikeRide] {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<BikeRide> = BikeRide.fetchRequestsWithDateRanges()[0] ?? BikeRide.fetchRequest()
        do {
            let items = try context.fetch(fetchRequest)
            return items
        }
        catch let error as NSError {
            print("Error getting BikeRides: \(error.localizedDescription), \(error.userInfo)")
        }
        return [BikeRide]()
    }
    
    static func bikeRidesInPast5Weeks() -> [BikeRide] {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<BikeRide> = BikeRide.fetchRequestsWithDateRanges()[2] ?? BikeRide.fetchRequest()
        do {
            let items = try context.fetch(fetchRequest)
            return items
        }
        catch let error as NSError {
            print("Error getting BikeRides: \(error.localizedDescription), \(error.userInfo)")
        }
        return [BikeRide]()
    }
    
    static func bikeRidesInPast30Weeks() -> [BikeRide] {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<BikeRide> = BikeRide.fetchRequestsWithDateRanges()[4] ?? BikeRide.fetchRequest()
        do {
            let items = try context.fetch(fetchRequest)
            return items
        }
        catch let error as NSError {
            print("Error getting BikeRides: \(error.localizedDescription), \(error.userInfo)")
        }
        return [BikeRide]()
    }
}

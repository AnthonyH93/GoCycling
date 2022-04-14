//
//  PersistenceController.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-18.
//

import Foundation
import CoreData
import CoreLocation

struct PersistenceController {
    // A singleton for entire app to use
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "GoCycling")
        
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        // Pin the viewContext to the current generation token and set it to keep itself up to date with local changes.
        container.viewContext.automaticallyMergesChangesFromParent = true

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
    
    // MARK: User preference methods
    func storeUserPreferences(unitsChoice: UnitsChoice, displayingMetrics: Bool, colourChoice: ColourChoice, largeMetrics: Bool, sortChoice: SortChoice, deletionConfirmation: Bool, deletionEnabled: Bool, iconIndex: Int, namedRoutes: Bool, selectedRoute: String) {
        let context = container.viewContext
        
        let newPreferences = UserPreferences(context: context)
        newPreferences.usingMetric = unitsChoice.id == "metric" ? true : false
        newPreferences.displayingMetrics = displayingMetrics
        newPreferences.colourChoice = colourChoice.rawValue
        newPreferences.largeMetrics = largeMetrics
        newPreferences.sortingChoice = sortChoice.rawValue
        newPreferences.deletionConfirmation = deletionConfirmation
        newPreferences.deletionEnabled = deletionEnabled
        newPreferences.iconIndex = iconIndex
        newPreferences.namedRoutes = namedRoutes
        newPreferences.selectedRoute = selectedRoute
        
        do {
            try context.save()
            print("Preferences saved")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // We only need 1 stored UserPreferences object, so update that single object instead of creating new ones
    func updateUserPreferences(existingPreferences: UserPreferences, unitsChoice: UnitsChoice, displayingMetrics: Bool, colourChoice: ColourChoice, largeMetrics: Bool, sortChoice: SortChoice, deletionConfirmation: Bool, deletionEnabled: Bool, iconIndex: Int, namedRoutes: Bool, selectedRoute: String) {
        let context = container.viewContext
        
        context.performAndWait {
            existingPreferences.usingMetric = unitsChoice.id == "metric" ? true : false
            existingPreferences.displayingMetrics = displayingMetrics
            existingPreferences.colourChoice = colourChoice.rawValue
            existingPreferences.largeMetrics = largeMetrics
            existingPreferences.sortingChoice = sortChoice.rawValue
            existingPreferences.deletionConfirmation = deletionConfirmation
            existingPreferences.deletionEnabled = deletionEnabled
            existingPreferences.iconIndex = iconIndex
            existingPreferences.namedRoutes = namedRoutes
            existingPreferences.selectedRoute = selectedRoute
            
            do {
                try context.save()
                print("Preferences updated")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    // MARK: Bike ride methods
    func storeBikeRide(locations: [CLLocation?], speeds: [CLLocationSpeed?], distance: Double, elevations: [CLLocationDistance?], startTime: Date, time: Double) {
        let context = container.viewContext
        
        var latitudes: [CLLocationDegrees] = []
        var longitudes: [CLLocationDegrees] = []
        var speedsValidated: [CLLocationSpeed] = []
        var elevationsValidated: [CLLocationDistance] = []
        
        for location in locations {
            // Only include coordinates where neither latitude nor longitude is nil
            if let currentLatitude = location?.coordinate.latitude {
                if let currentLongitude = location?.coordinate.longitude {
                    latitudes.append(currentLatitude)
                    longitudes.append(currentLongitude)
                }
            }
        }
        
        for speed in speeds {
            // Only store non nil speeds
            if let currentSpeed = speed {
                speedsValidated.append(currentSpeed)
            }
        }
        
        for elevation in elevations {
            // Only store non nil altitudes
            if let currentElevation = elevation {
                elevationsValidated.append(currentElevation)
            }
        }
        
        let newBikeRide = BikeRide(context: context)
        newBikeRide.cyclingLatitudes = latitudes
        newBikeRide.cyclingLongitudes = longitudes
        newBikeRide.cyclingSpeeds = speedsValidated
        newBikeRide.cyclingDistance = distance
        newBikeRide.cyclingElevations = elevationsValidated
        newBikeRide.cyclingStartTime = startTime
        newBikeRide.cyclingTime = time
        // Default category
        newBikeRide.cyclingRouteName = "Uncategorized"
        
        do {
            try context.save()
            print("Bike ride saved")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // Function to update the route name of a saved bike ride
    func updateBikeRideRouteName(existingBikeRide: BikeRide, latitudes: [CLLocationDegrees], longitudes: [CLLocationDegrees], speeds: [CLLocationSpeed], distance: Double, elevations: [CLLocationDistance], startTime: Date, time: Double, routeName: String) {
        let context = container.viewContext
        
        context.performAndWait {
            existingBikeRide.cyclingLatitudes = latitudes
            existingBikeRide.cyclingLongitudes = longitudes
            existingBikeRide.cyclingSpeeds = speeds
            existingBikeRide.cyclingDistance = distance
            existingBikeRide.cyclingElevations = elevations
            existingBikeRide.cyclingStartTime = startTime
            existingBikeRide.cyclingTime = time
            existingBikeRide.cyclingRouteName = routeName
            
            do {
                try context.save()
                print("Bike ride updated")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func deleteAllBikeRides() {
        let context = container.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BikeRide")
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(fetchRequest)
            for managedObject in results {
                if let managedObjectData: NSManagedObject = managedObject as? NSManagedObject {
                    context.delete(managedObjectData)
                }
            }
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateBikeRideCategories(oldCategoriesToUpdate: [String], newCategoryNames: [String]) {
        let context = container.viewContext
        if (newCategoryNames.count > 0 && (newCategoryNames.count == oldCategoriesToUpdate.count)) {
            for (index, name) in newCategoryNames.enumerated() {
                let fetchRequest: NSFetchRequest<BikeRide> = BikeRide.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "cyclingRouteName == %@", oldCategoriesToUpdate[index])
                do {
                    let results = try context.fetch(fetchRequest)
                    for ride in results {
                        updateBikeRideRouteName(
                            existingBikeRide: ride,
                            latitudes: ride.cyclingLatitudes,
                            longitudes: ride.cyclingLongitudes,
                            speeds: ride.cyclingSpeeds,
                            distance: ride.cyclingDistance,
                            elevations: ride.cyclingElevations,
                            startTime: ride.cyclingStartTime,
                            time: ride.cyclingTime,
                            routeName: name)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    // Function to rename all routes of a given category to Uncategorized
    func removeCategory(categoryName: String) {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<BikeRide> = BikeRide.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "cyclingRouteName == %@", categoryName)
        do {
            let results = try context.fetch(fetchRequest)
            for ride in results {
                updateBikeRideRouteName(
                    existingBikeRide: ride,
                    latitudes: ride.cyclingLatitudes,
                    longitudes: ride.cyclingLongitudes,
                    speeds: ride.cyclingSpeeds,
                    distance: ride.cyclingDistance,
                    elevations: ride.cyclingElevations,
                    startTime: ride.cyclingStartTime,
                    time: ride.cyclingTime,
                    routeName: "Uncategorized")
            }
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: Records methods
    func storeRecords(totalDistance: Double, totalTime: Double, totalRoutes: Int64, unlockedIcons: [Bool], longestDistance: Double, longestTime: Double, fastestAvgSpeed: Double, longestDistanceDate: Date?, longestTimeDate: Date?, fastestAvgSpeedDate: Date?) {
        let context = container.viewContext
        
        let newRecords = Records(context: context)
        newRecords.totalCyclingDistance = totalDistance
        newRecords.totalCyclingTime = totalTime
        newRecords.totalCyclingRoutes = totalRoutes
        newRecords.unlockedIcons = unlockedIcons
        newRecords.longestCyclingDistance = longestDistance
        newRecords.longestCyclingTime = longestTime
        newRecords.fastestAverageSpeed = fastestAvgSpeed
        newRecords.longestCyclingDistanceDate = longestDistanceDate
        newRecords.longestCyclingTimeDate = longestTimeDate
        newRecords.fastestAverageSpeedDate = fastestAvgSpeedDate
        
        // Update unlocked icons array
        newRecords.setUnlockedIcons()
        
        do {
            try context.save()
            print("Records saved")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // Only need to store one records object, use this method to update the existing object
    func updateRecords(existingRecords: Records, totalDistance: Double, totalTime: Double, totalRoutes: Int64, longestDistance: Double, longestTime: Double, fastestAvgSpeed: Double, longestDistanceDate: Date?, longestTimeDate: Date?, fastestAvgSpeedDate: Date?) {
        let context = container.viewContext
        
        context.performAndWait {
            existingRecords.totalCyclingDistance = totalDistance
            existingRecords.totalCyclingTime = totalTime
            existingRecords.totalCyclingRoutes = totalRoutes
            existingRecords.longestCyclingDistance = longestDistance
            existingRecords.longestCyclingTime = longestTime
            existingRecords.fastestAverageSpeed = fastestAvgSpeed
            existingRecords.longestCyclingDistanceDate = longestDistanceDate
            existingRecords.longestCyclingTimeDate = longestTimeDate
            existingRecords.fastestAverageSpeedDate = fastestAvgSpeedDate
            
            // Update unlocked icons array
            existingRecords.setUnlockedIcons()
            
            do {
                try context.save()
                print("Records updated")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

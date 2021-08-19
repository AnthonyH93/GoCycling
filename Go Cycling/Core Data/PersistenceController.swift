//
//  PersistenceController.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-18.
//

import Foundation
import CoreData

struct PersistenceController {
    // A singleton for entire app to use
    static let shared = PersistenceController()

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
    
    func storeBikeRide(locations: [CLLocation?], speeds: [CLLocationSpeed?], distance: Double, elevations: [CLLocationDistance?], startTime: Date, time: Double) {
        let context = container.viewContext
        
        var latitudes: [CLLocationDegrees] = []
        var longitudes: [CLLocationDegrees] = []
        var speedsValidated: [CLLocationSpeed] = []
        var elevationsValidated: [CLLocationDistance] = []
        
        for location in locations {
            latitudes.append(location?.coordinate.latitude ?? 0.0)
            longitudes.append(location?.coordinate.longitude ?? 0.0)
        }
        
        for speed in speeds {
            speedsValidated.append(speed ?? 0.0)
        }
        
        for elevation in elevations {
            if let currentElevation = elevation {
                elevationsValidated.append(currentElevation)
            }
            else {
                // Skip
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
        // This functionality will be added in a future update
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
}

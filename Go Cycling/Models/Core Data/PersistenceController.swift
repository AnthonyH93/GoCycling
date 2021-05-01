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
    
    func storeUserPreferences(unitsChoice: UnitsChoice, displayingMetrics: Bool, colourChoice: ColourChoice, largeMetrics: Bool, sortChoice: SortChoice) {
        let context = container.viewContext
        
        let newPreferences = UserPreferences(context: context)
        newPreferences.usingMetric = unitsChoice.id == "metric" ? true : false
        newPreferences.displayingMetrics = displayingMetrics
        newPreferences.colourChoice = colourChoice.rawValue
        newPreferences.largeMetrics = largeMetrics
        newPreferences.sortingChoice = sortChoice.rawValue
        
        do {
            try context.save()
            print("Preferences saved")
        } catch {
            print(error.localizedDescription)
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
        
        do {
            try context.save()
            print("Bike ride saved")
        } catch {
            print(error.localizedDescription)
        }
    }
}

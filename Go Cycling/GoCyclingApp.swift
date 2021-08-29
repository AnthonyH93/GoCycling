//
//  Go_CyclingApp.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-03-14.
//

import SwiftUI

@main
struct GoCyclingApp: App {
    
    let persistenceController = PersistenceController.shared
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject var preferences: PreferencesStorage
    @StateObject var bikeRides: BikeRideStorage
    @StateObject var records: RecordsStorage
    @StateObject var cyclingStatus = CyclingStatus()
    
    init() {
        // Retrieve stored data to be used by all views - create state objects for environment objects
        let managedObjectContext = persistenceController.container.viewContext
        let preferencesStorage = PreferencesStorage(managedObjectContext: managedObjectContext)
        self._preferences = StateObject(wrappedValue: preferencesStorage)
        let bikeRidesStorage = BikeRideStorage(managedObjectContext: managedObjectContext)
        self._bikeRides = StateObject(wrappedValue: bikeRidesStorage)
        let recordsStroage = RecordsStorage(managedObjectContext: managedObjectContext)
        self._records = StateObject(wrappedValue: recordsStroage)
    }

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(preferences)
                .environmentObject(bikeRides)
                .environmentObject(records)
                .environmentObject(cyclingStatus)
                .onAppear(perform: {
                    // Default namedRoutes to true on version 1.1.0
                    if (!UserDefaults.standard.bool(forKey: "didLaunch1.1.0Before")) {
                        UserDefaults.standard.set(true, forKey: "didLaunch1.1.0Before")
                        persistenceController.updateUserPreferences(
                            existingPreferences: preferences.storedPreferences[0],
                            unitsChoice: preferences.storedPreferences[0].metricsChoiceConverted,
                            displayingMetrics: preferences.storedPreferences[0].displayingMetrics,
                            colourChoice: preferences.storedPreferences[0].colourChoiceConverted,
                            largeMetrics: preferences.storedPreferences[0].largeMetrics,
                            sortChoice: preferences.storedPreferences[0].sortingChoiceConverted,
                            deletionConfirmation: preferences.storedPreferences[0].deletionConfirmation,
                            deletionEnabled: preferences.storedPreferences[0].deletionEnabled,
                            iconIndex: preferences.storedPreferences[0].iconIndex,
                            namedRoutes: true,
                            selectedRoute: "")
                        // Changed current "Unnamed" to "Uncategorized"
                        for ride in bikeRides.storedBikeRides {
                            persistenceController.updateBikeRideRouteName(
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
                    }
                })
        }
        .onChange(of: scenePhase) { _ in
            persistenceController.save()
        }
    }
}

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
    
    init() {
        let managedObjectContext = persistenceController.container.viewContext
        let preferencesStorage = PreferencesStorage(managedObjectContext: managedObjectContext)
        self._preferences = StateObject(wrappedValue: preferencesStorage)
        let bikeRidesStorage = BikeRideStorage(managedObjectContext: managedObjectContext)
        self._bikeRides = StateObject(wrappedValue: bikeRidesStorage)
    }

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(preferences)
                .environmentObject(bikeRides)
        }
        .onChange(of: scenePhase) { _ in
            persistenceController.save()
        }
    }
}

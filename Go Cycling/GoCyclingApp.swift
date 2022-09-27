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
    
    @StateObject var bikeRides: BikeRideStorage
    @StateObject var cyclingStatus = CyclingStatus()
    @StateObject var preferences = Preferences.shared
    @StateObject var records = CyclingRecords.shared
    
    init() {
        // Clear iCloud key value pairs
//        let allKeys = NSUbiquitousKeyValueStore.default.dictionaryRepresentation.keys
//        for key in allKeys {
//            NSUbiquitousKeyValueStore.default.removeObject(forKey: key)
//        }
        
        // Retrieve stored data to be used by all views - create state objects for environment objects
        let managedObjectContext = persistenceController.container.viewContext
        let bikeRidesStorage = BikeRideStorage(managedObjectContext: managedObjectContext)
        self._bikeRides = StateObject(wrappedValue: bikeRidesStorage)
    }

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(bikeRides)
                .environmentObject(records)
                .environmentObject(cyclingStatus)
                .environmentObject(preferences)
                .onAppear(perform: {
                    
                    // For first launch with UserPreferences set
                    if (!NSUbiquitousKeyValueStore.default.bool(forKey: "didLaunch1.4.0Before") || !UserDefaults.standard.bool(forKey: "didLaunch1.4.0Before")) {
                        NSUbiquitousKeyValueStore.default.set(true, forKey: "didLaunch1.4.0Before")
                        UserDefaults.standard.set(true, forKey: "didLaunch1.4.0Before")
                        // Migrate existing UserPreferences
                        if let oldPreferences = UserPreferences.savedPreferences() {
                            preferences.initialUserPreferencesMigration(existingPreferences: oldPreferences)
                        }
                        // Migrate existing Records
                        if let oldRecords = Records.getStoredRecords() {
                            records.initialRecordsMigration(existingRecords: oldRecords, existingBikeRides: bikeRides.storedBikeRides)
                        }
                    }
                    
                    // Check if iCloud is available
                    if FileManager.default.ubiquityIdentityToken != nil {
                        if (!NSUbiquitousKeyValueStore.default.bool(forKey: "didLaunch1.4.0Before")) {
                            NSUbiquitousKeyValueStore.default.set(true, forKey: "didLaunch1.4.0Before")
                        }
                    }
                })
        }
        .onChange(of: scenePhase) { _ in
            persistenceController.save()
        }
    }
}

//
//  Go_CyclingApp.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-03-14.
//

import SwiftUI
import TelemetryDeck

@main
struct GoCyclingApp: App {
    
    let persistenceController = PersistenceController.shared
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject var bikeRides: BikeRideStorage
    @StateObject var cyclingStatus = CyclingStatus()
    @StateObject var preferences = Preferences.shared
    @StateObject var records = CyclingRecords.shared

    // Result of importing a GPX file opened from another app (Files, Mail, share sheet, ...)
    @State private var openedFileImportMessage: String? = nil
    
    init() {
        // Initialize TelemetryDeck
        // Attempt to find App ID
        if let appID = Bundle.main.object(forInfoDictionaryKey: "GoCyclingAppID") {
            // Read telemetry preference before singleton init — missing key defaults to true (opted in)
            let telemetryEnabled = UserDefaults.standard.object(forKey: Preferences.telemetryEnabledKey) != nil
                ? UserDefaults.standard.bool(forKey: Preferences.telemetryEnabledKey)
                : true
            TelemetryManager.setup(
                TelemetryManager.TelemetryManagerConfig(appID: appID as! String),
                enabled: telemetryEnabled
            )
        }
        
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
                    
                    // Disable auto lock if that setting is enabled
                    if (preferences.autoLockDisabled) {
                        UIApplication.shared.isIdleTimerDisabled = true
                    }

                    // Gate mid-session telemetry signals based on stored preference
                    TelemetryManager.sharedTelemetryManager.userTelemetryEnabled = preferences.telemetryEnabled

                    // Backfill cyclingAverageSpeed for rides saved before that attribute existed
                    persistenceController.backfillAverageSpeedIfNeeded()
                })
                .onOpenURL { url in
                    importOpenedFile(url)
                }
                .alert(isPresented: Binding(
                    get: { openedFileImportMessage != nil },
                    set: { if !$0 { openedFileImportMessage = nil } }
                )) {
                    Alert(title: Text("GPX Import"), message: Text(openedFileImportMessage ?? ""), dismissButton: .default(Text("OK")))
                }
        }
        .onChange(of: scenePhase) { _ in
            persistenceController.save()
        }
    }

    private func importOpenedFile(_ url: URL) {
        guard url.isFileURL, url.pathExtension.lowercased() == "gpx" else { return }
        TelemetryManager.sharedTelemetryManager.sendCyclingSignal(tab: TelemetryTab.History, action: TelemetryCyclingAction.OpenGPX)

        GPXImporter.importFiles(at: [url], container: persistenceController.container) { summary in
            // Files handed to the app are copied into Documents/Inbox; remove the copy once imported
            if url.pathComponents.contains("Inbox") {
                try? FileManager.default.removeItem(at: url)
            }
            openedFileImportMessage = summary.message
        }
    }
}

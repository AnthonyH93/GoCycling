//
//  SyncSettingsView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2022-08-18.
//

import SwiftUI

struct SyncSettingsView: View {
    var persistenceController = PersistenceController.shared
    
    @EnvironmentObject var preferences: Preferences
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    @State private var showingAlert = false
    
    // Need to show the Health app authorization if that setting is toggled
    @StateObject var healthKitManager = HealthKitManager.healthKitManager
    
    // Access singleton TelemetryManager class object
    let telemetryManager = TelemetryManager.sharedTelemetryManager
    let telemetryTab = TelemetryTab.Settings
    let telemetryTabSection = TelemetrySettingsSection.Sync
    
    var body: some View {
        // In iOS 16+ forms can have labels attached to content
        if #available(iOS 16.0, *) {
            // iCloud sync setting
            LabeledContent {
                Toggle("", isOn: $preferences.iCloudOn)
                    .onChange(of: preferences.iCloudOn) { value in
                        self.updateSyncPreference(preference: CustomizablePreferences.iCloudSync, value: value)
                        self.showingAlert = true
                    }
                // Confirmation alert about restarting app due to iCloud setting change
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text("Restart is Required"),
                              message: Text("Please restart the application to \(preferences.iCloudOn ? "enable" : "disable") iCloud syncing for cycling routes.")
                              
                        )
                    }
            } label: {
                Label("iCloud", systemImage: "icloud")
                Text("Sync all data with iCloud")
            }
            // HealthKit sync setting
            LabeledContent {
                Toggle("", isOn: $preferences.healthSyncEnabled)
                    .onChange(of: preferences.healthSyncEnabled) { value in
                        self.updateSyncPreference(preference: CustomizablePreferences.healthSyncEnabled, value: value)
                        if value {
                            healthKitManager.requestAuthorization()
                        }
                    }
            } label: {
                Label("Health", systemImage: "heart")
                Text("Upload data to the Health app")
            }
        } else {
            Toggle("iCloud Sync", isOn: $preferences.iCloudOn)
                .onChange(of: preferences.iCloudOn) { value in
                    self.updateSyncPreference(preference: CustomizablePreferences.iCloudSync, value: value)
                    self.showingAlert = true
                }
                // Confirmation alert about restarting app due to iCloud setting change
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Restart is Required"),
                          message: Text("Please restart the application to \(preferences.iCloudOn ? "enable" : "disable") iCloud syncing for cycling routes.")
                            
                    )
                }
            // TODO: Make sure this works in iOS 15
            Toggle("Health Sync", isOn: $preferences.healthSyncEnabled)
                .onChange(of: preferences.healthSyncEnabled) { value in
                    self.updateSyncPreference(preference: CustomizablePreferences.healthSyncEnabled, value: value)
                    if value {
                        healthKitManager.requestAuthorization()
                    }
                }
        }
    }
    
    func updateSyncPreference(preference: CustomizablePreferences, value: Bool) {
        preferences.updateBoolPreference(preference: preference, value: value)
        
        // Send the correct telemetry signal
        var telemetryAction = TelemetrySettingsAction.iCloud
        switch preference {
        case .healthSyncEnabled:
            telemetryAction = TelemetrySettingsAction.Health
        default:
            telemetryAction = TelemetrySettingsAction.iCloud
        }
        
        telemetryManager.sendSettingsSignal(
            section: telemetryTabSection,
            action: telemetryAction
        )
    }
}

struct SyncSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SyncSettingsView()
    }
}

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
    let telemetryTabSection = TelemetrySettingsSection.Sync
    
    var iCloudBinding: Binding<Bool> {
        Binding(
            get: { preferences.iCloudOn },
            set: { preferences.updateBoolPreference(preference: CustomizablePreferences.iCloudSync, value: $0) }
        )
    }

    var healthBinding: Binding<Bool> {
        Binding(
            get: { preferences.healthSyncEnabled },
            set: { preferences.updateBoolPreference(preference: CustomizablePreferences.healthSyncEnabled, value: $0) }
        )
    }

    var body: some View {
        // In iOS 16+ forms can have labels attached to content
        if #available(iOS 16.0, *) {
            // iCloud sync setting
            LabeledContent {
                Toggle("", isOn: iCloudBinding)
                    .onChange(of: preferences.iCloudOn) { _ in
                        self.showingAlert = true
                        telemetryManager.sendSettingsSignal(section: telemetryTabSection, action: TelemetrySettingsAction.iCloud)
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
                    .fixedSize(horizontal: false, vertical: true)
            }
            // HealthKit sync setting
            LabeledContent {
                Toggle("", isOn: healthBinding)
                    .onChange(of: preferences.healthSyncEnabled) { value in
                        if value { healthKitManager.requestAuthorization() }
                        telemetryManager.sendSettingsSignal(section: telemetryTabSection, action: TelemetrySettingsAction.Health)
                    }
            } label: {
                Label("Health", systemImage: "heart")
                Text("Upload data to the Health app")
                    .fixedSize(horizontal: false, vertical: true)
            }
        } else {
            Toggle("iCloud Sync", isOn: iCloudBinding)
                .onChange(of: preferences.iCloudOn) { _ in
                    self.showingAlert = true
                    telemetryManager.sendSettingsSignal(section: telemetryTabSection, action: TelemetrySettingsAction.iCloud)
                }
                // Confirmation alert about restarting app due to iCloud setting change
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Restart is Required"),
                          message: Text("Please restart the application to \(preferences.iCloudOn ? "enable" : "disable") iCloud syncing for cycling routes.")
                    )
                }
            Toggle("Health Sync", isOn: healthBinding)
                .onChange(of: preferences.healthSyncEnabled) { value in
                    if value { healthKitManager.requestAuthorization() }
                    telemetryManager.sendSettingsSignal(section: telemetryTabSection, action: TelemetrySettingsAction.Health)
                }
        }
    }
}

struct SyncSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SyncSettingsView()
    }
}

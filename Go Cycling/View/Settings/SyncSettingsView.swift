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
        // iCloud sync setting
        Toggle(isOn: iCloudBinding) {
            Label {
                VStack(alignment: .leading, spacing: 2) {
                    Text("iCloud")
                    Text("Sync all data with iCloud")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } icon: {
                Image(systemName: "icloud")
            }
        }
        .onChange(of: preferences.iCloudOn) { _ in
            self.showingAlert = true
            telemetryManager.sendSettingsSignal(section: telemetryTabSection, action: TelemetrySettingsAction.iCloud)
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Restart is Required"),
                  message: Text("Please restart the application to \(preferences.iCloudOn ? "enable" : "disable") iCloud syncing for cycling routes.")
            )
        }
        // HealthKit sync setting
        Toggle(isOn: healthBinding) {
            Label {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Health")
                    Text("Upload data to the Health app")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } icon: {
                Image(systemName: "heart")
            }
        }
        .onChange(of: preferences.healthSyncEnabled) { value in
            if value { healthKitManager.requestAuthorization() }
            telemetryManager.sendSettingsSignal(section: telemetryTabSection, action: TelemetrySettingsAction.Health)
        }
    }
}

struct SyncSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SyncSettingsView()
    }
}

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
    
    var body: some View {
        // In iOS 16+ forms can have labels attached to content
        if #available(iOS 16.0, *) {
            LabeledContent {
                Toggle("", isOn: $preferences.iCloudOn)
                    .onChange(of: preferences.iCloudOn) { value in
                        preferences.updateBoolPreference(preference: CustomizablePreferences.iCloudSync, value: value)
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
        } else {
            Toggle("iCloud Sync", isOn: $preferences.iCloudOn)
                .onChange(of: preferences.iCloudOn) { value in
                    preferences.updateBoolPreference(preference: CustomizablePreferences.iCloudSync, value: value)
                    self.showingAlert = true
                }
                // Confirmation alert about restarting app due to iCloud setting change
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Restart is Required"),
                          message: Text("Please restart the application to \(preferences.iCloudOn ? "enable" : "disable") iCloud syncing for cycling routes.")
                            
                    )
                }
        }
    }
}

struct SyncSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SyncSettingsView()
    }
}

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
    
    var body: some View {
        Toggle("iCloud Sync", isOn: $preferences.iCloudOn)
            .onChange(of: preferences.iCloudOn) { value in
                preferences.updateBoolPreference(preference: CustomizablePreferences.iCloudSync, value: value)
            }
    }
}

struct SyncSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SyncSettingsView()
    }
}

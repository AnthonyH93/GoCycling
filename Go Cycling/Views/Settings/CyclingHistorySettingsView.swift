//
//  CyclingHistorySettingsView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-05-06.
//

import SwiftUI

struct CyclingHistorySettingsView: View {
    let persistenceController = PersistenceController.shared
    
    @EnvironmentObject var newPreferences: Preferences
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    var body: some View {
        Toggle("Route Categorization Enabled", isOn: $newPreferences.namedRoutes)
            .onChange(of: newPreferences.namedRoutes) { value in
                newPreferences.updateBoolPreference(preference: CustomizablePreferences.namedRoutes, value: value)
            }
        Toggle("Deletion Enabled", isOn: $newPreferences.deletionEnabled)
            .onChange(of: newPreferences.deletionEnabled) { value in
                newPreferences.updateBoolPreference(preference: CustomizablePreferences.deletionEnabled, value: value)
            }
        Toggle("Deletion Confirmation Alert", isOn: $newPreferences.deletionConfirmation)
            .onChange(of: newPreferences.deletionConfirmation) { value in
                newPreferences.updateBoolPreference(preference: CustomizablePreferences.deletionConfirmation, value: value)
            }
    }
}

struct CyclingHistorySettingsView_Previews: PreviewProvider {
    static var previews: some View {
        CyclingHistorySettingsView()
    }
}

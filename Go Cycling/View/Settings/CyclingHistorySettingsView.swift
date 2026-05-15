//
//  CyclingHistorySettingsView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-05-06.
//

import SwiftUI

struct CyclingHistorySettingsView: View {
    let persistenceController = PersistenceController.shared
    
    @EnvironmentObject var preferences: Preferences
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    // Access singleton TelemetryManager class object
    let telemetryManager = TelemetryManager.sharedTelemetryManager
    let telemetryTabSection = TelemetrySettingsSection.History
    
    var body: some View {
        Toggle("Route Categorization Enabled", isOn: Binding(
            get: { preferences.namedRoutes },
            set: { value in
                preferences.updateBoolPreference(preference: CustomizablePreferences.namedRoutes, value: value)
                telemetryManager.sendSettingsSignal(section: telemetryTabSection, action: TelemetrySettingsAction.RoutesEnabled)
            }
        ))
        Toggle("Deletion Enabled", isOn: Binding(
            get: { preferences.deletionEnabled },
            set: { value in
                preferences.updateBoolPreference(preference: CustomizablePreferences.deletionEnabled, value: value)
                telemetryManager.sendSettingsSignal(section: telemetryTabSection, action: TelemetrySettingsAction.DeletionEnabled)
            }
        ))
        Toggle("Deletion Confirmation Alert", isOn: Binding(
            get: { preferences.deletionConfirmation },
            set: { value in
                preferences.updateBoolPreference(preference: CustomizablePreferences.deletionConfirmation, value: value)
                telemetryManager.sendSettingsSignal(section: telemetryTabSection, action: TelemetrySettingsAction.DeletionConfirmtion)
            }
        ))
    }
}

struct CyclingHistorySettingsView_Previews: PreviewProvider {
    static var previews: some View {
        CyclingHistorySettingsView()
    }
}

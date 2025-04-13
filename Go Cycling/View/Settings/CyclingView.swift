//
//  CyclingView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2024-02-19.
//

import SwiftUI

struct CyclingView: View {
    let persistenceController = PersistenceController.shared
    
    @EnvironmentObject var preferences: Preferences
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    // Access singleton TelemetryManager class object
    let telemetryManager = TelemetryManager.sharedTelemetryManager
    let telemetryTabSection = TelemetrySettingsSection.Cycling
    
    var body: some View {
        Toggle("Disable Auto-Lock", isOn: $preferences.autoLockDisabled)
            .onChange(of: preferences.autoLockDisabled) { value in
                UIApplication.shared.isIdleTimerDisabled = value
                preferences.updateBoolPreference(preference: CustomizablePreferences.autoLockDisabled, value: value)
                
                telemetryManager.sendSettingsSignal(
                    section: telemetryTabSection,
                    action: TelemetrySettingsAction.AutoLock
                )
            }
    }
}

struct CyclingView_Previews: PreviewProvider {
    static var previews: some View {
        CyclingView()
    }
}

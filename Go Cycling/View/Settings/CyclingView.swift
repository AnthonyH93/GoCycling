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
        Toggle("Disable Auto-Lock", isOn: Binding(
            get: { preferences.autoLockDisabled },
            set: { preferences.updateBoolPreference(preference: CustomizablePreferences.autoLockDisabled, value: $0) }
        ))
        .onChange(of: preferences.autoLockDisabled) { value in
            UIApplication.shared.isIdleTimerDisabled = value
            telemetryManager.sendSettingsSignal(section: telemetryTabSection, action: TelemetrySettingsAction.AutoLock)
        }
    }
}

struct CyclingView_Previews: PreviewProvider {
    static var previews: some View {
        CyclingView()
    }
}

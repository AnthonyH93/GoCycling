//
//  PrivacySettingsView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2026-05-13.
//

import SwiftUI

struct PrivacySettingsView: View {
    @EnvironmentObject var preferences: Preferences

    let telemetryManager = TelemetryManager.sharedTelemetryManager
    let telemetryTabSection = TelemetrySettingsSection.Privacy

    var telemetryBinding: Binding<Bool> {
        Binding(
            get: { preferences.telemetryEnabled },
            set: { preferences.updateBoolPreference(preference: CustomizablePreferences.telemetryEnabled, value: $0) }
        )
    }

    var body: some View {
        Toggle("Share Anonymous Analytics", isOn: telemetryBinding)
            .onChange(of: preferences.telemetryEnabled) { value in
                TelemetryManager.sharedTelemetryManager.userTelemetryEnabled = value
                telemetryManager.sendSettingsSignal(section: telemetryTabSection, action: TelemetrySettingsAction.TelemetryOptOut)
            }
    }
}

struct PrivacySettingsView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacySettingsView()
    }
}

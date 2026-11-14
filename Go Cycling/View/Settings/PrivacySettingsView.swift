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

    // Shows the closest option in the user's units for whatever distance is stored
    var routePrivacyBinding: Binding<RoutePrivacy.Option> {
        Binding(
            get: { RoutePrivacy.nearestOption(to: preferences.routePrivacyDistance, usingMetric: preferences.usingMetric) },
            set: { option in
                preferences.updateRoutePrivacyDistance(option.metres)
                telemetryManager.sendSettingsSignal(section: telemetryTabSection, action: TelemetrySettingsAction.RoutePrivacy)
            }
        )
    }

    var body: some View {
        Picker("Hide Start & End of Routes", selection: routePrivacyBinding) {
            ForEach(RoutePrivacy.options(usingMetric: preferences.usingMetric)) { option in
                Text(option.label).tag(option)
            }
        }
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

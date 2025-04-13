//
//  UnitsView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-18.
//

import SwiftUI

struct UnitsView: View {
    let persistenceController = PersistenceController.shared
    
    @EnvironmentObject var preferences: Preferences
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    // Access singleton TelemetryManager class object
    let telemetryManager = TelemetryManager.sharedTelemetryManager
    let telemetryTabSection = TelemetrySettingsSection.Metrics
    
    var body: some View {
        HStack {
            Text("Prefered Units")
            Spacer()
            Picker("Prefered Units", selection: $preferences.metricsChoiceConverted) {
                Text("Imperial").tag(UnitsChoice.imperial)
                Text("Metric").tag(UnitsChoice.metric)
                    .onChange(of: preferences.metricsChoiceConverted) { _ in
                        preferences.updateBoolPreference(preference: CustomizablePreferences.metric, value: preferences.usingMetric)
                        
                        telemetryManager.sendSettingsSignal(
                            section: telemetryTabSection,
                            action: TelemetrySettingsAction.Units
                        )
                    }
            }
            .frame(maxWidth: 150)
            .pickerStyle(SegmentedPickerStyle())
        }
        Toggle("Display Metrics on Map", isOn: $preferences.displayingMetrics)
            .onChange(of: preferences.displayingMetrics) { value in
                preferences.updateBoolPreference(preference: CustomizablePreferences.displayingMetrics, value: value)
                
                telemetryManager.sendSettingsSignal(
                    section: telemetryTabSection,
                    action: TelemetrySettingsAction.MetricsOnMap
                )
            }
        Toggle("Large Metrics View", isOn: $preferences.largeMetrics)
            .onChange(of: preferences.largeMetrics) { value in
                preferences.updateBoolPreference(preference: CustomizablePreferences.largeMetrics, value: value)
                
                telemetryManager.sendSettingsSignal(
                    section: telemetryTabSection,
                    action: TelemetrySettingsAction.LargeMetrics
                )
            }
    }
}

struct UnitsView_Previews: PreviewProvider {
    static var previews: some View {
        UnitsView()
    }
}

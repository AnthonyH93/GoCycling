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
            Picker("Prefered Units", selection: Binding(
                get: { preferences.metricsChoiceConverted },
                set: { value in
                    preferences.updateBoolPreference(preference: CustomizablePreferences.metric, value: value == .metric)
                    telemetryManager.sendSettingsSignal(section: telemetryTabSection, action: TelemetrySettingsAction.Units)
                }
            )) {
                Text("Imperial").tag(UnitsChoice.imperial)
                Text("Metric").tag(UnitsChoice.metric)
            }
            .frame(maxWidth: 150)
            .pickerStyle(.segmented)
        }
        Toggle("Display Metrics on Map", isOn: Binding(
            get: { preferences.displayingMetrics },
            set: { value in
                preferences.updateBoolPreference(preference: CustomizablePreferences.displayingMetrics, value: value)
                telemetryManager.sendSettingsSignal(section: telemetryTabSection, action: TelemetrySettingsAction.MetricsOnMap)
            }
        ))
        HStack {
            Text("Map Type")
            Spacer()
            Picker("Map Type", selection: Binding(
                get: { preferences.mapTypeChoiceConverted },
                set: { value in
                    preferences.updateStringPreference(preference: .mapTypeChoice, value: value.rawValue)
                }
            )) {
                ForEach(MapTypeChoice.allCases, id: \.self) { choice in
                    Text(choice.rawValue).tag(choice)
                }
            }
            .pickerStyle(.menu)
        }
    }
}

struct UnitsView_Previews: PreviewProvider {
    static var previews: some View {
        UnitsView()
    }
}

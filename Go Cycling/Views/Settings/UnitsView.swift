//
//  UnitsView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-18.
//

import SwiftUI

struct UnitsView: View {
    let persistenceController = PersistenceController.shared
    
    @EnvironmentObject var newPreferences: Preferences
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    var body: some View {
        HStack {
            Text("Prefered Units")
            Spacer()
            Picker("Prefered Units", selection: $newPreferences.metricsChoiceConverted) {
                Text("Imperial").tag(UnitsChoice.imperial)
                Text("Metric").tag(UnitsChoice.metric)
                    .onChange(of: newPreferences.metricsChoiceConverted) { _ in
                        newPreferences.updateBoolPreference(preference: CustomizablePreferences.metric, value: newPreferences.usingMetric)
                    }
            }
            .frame(maxWidth: 150)
            .pickerStyle(SegmentedPickerStyle())
        }
        Toggle("Display Metrics on Map", isOn: $newPreferences.displayingMetrics)
            .onChange(of: newPreferences.displayingMetrics) { value in
                newPreferences.updateBoolPreference(preference: CustomizablePreferences.displayingMetrics, value: value)
            }
        Toggle("Large Metrics View", isOn: $newPreferences.largeMetrics)
            .onChange(of: newPreferences.largeMetrics) { value in
                newPreferences.updateBoolPreference(preference: CustomizablePreferences.largeMetrics, value: value)
            }
    }
}

struct UnitsView_Previews: PreviewProvider {
    static var previews: some View {
        UnitsView()
    }
}

//
//  UnitsView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-18.
//

import SwiftUI

struct UnitsView: View {
    let persistenceController = PersistenceController.shared
    
    @EnvironmentObject var preferences: PreferencesStorage
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    var body: some View {
//        Toggle("Use Metric Units", isOn: $preferences.storedPreferences[0].usingMetric)
//            .onChange(of: preferences.storedPreferences[0].usingMetric) { value in
//                persistenceController.storeUserPreferences(
//                    usingMetric: preferences.storedPreferences[0].usingMetric,
//                    displayingMetrics: preferences.storedPreferences[0].displayingMetrics,
//                    colourChoice: preferences.storedPreferences[0].colourChoiceConverted,
//                    largeMetrics: preferences.storedPreferences[0].largeMetrics)
//            }
        HStack {
            Text("Prefered Units")
            Spacer()
            Picker("Prefered Units", selection: $preferences.storedPreferences[0].metricsChoiceConverted) {
                Text("Imperial").tag(UnitsChoice.imperial)
                Text("Metric").tag(UnitsChoice.metric)
                    .onChange(of: preferences.storedPreferences[0].metricsChoiceConverted) { value in
                        persistenceController.storeUserPreferences(
                            unitsChoice: preferences.storedPreferences[0].metricsChoiceConverted,
                            displayingMetrics: preferences.storedPreferences[0].displayingMetrics,
                            colourChoice: preferences.storedPreferences[0].colourChoiceConverted,
                            largeMetrics: preferences.storedPreferences[0].largeMetrics)
                    }
            }
            .frame(maxWidth: 150)
            .pickerStyle(SegmentedPickerStyle())
        }
        Toggle("Display Metrics on Map", isOn: $preferences.storedPreferences[0].displayingMetrics)
            .onChange(of: preferences.storedPreferences[0].displayingMetrics) { value in
                persistenceController.storeUserPreferences(
                    unitsChoice: preferences.storedPreferences[0].metricsChoiceConverted,
                    displayingMetrics: preferences.storedPreferences[0].displayingMetrics,
                    colourChoice: preferences.storedPreferences[0].colourChoiceConverted,
                    largeMetrics: preferences.storedPreferences[0].largeMetrics)
            }
        Toggle("Large Metrics View", isOn: $preferences.storedPreferences[0].largeMetrics)
            .onChange(of: preferences.storedPreferences[0].largeMetrics) { value in
                persistenceController.storeUserPreferences(
                    unitsChoice: preferences.storedPreferences[0].metricsChoiceConverted,
                    displayingMetrics: preferences.storedPreferences[0].displayingMetrics,
                    colourChoice: preferences.storedPreferences[0].colourChoiceConverted,
                    largeMetrics: preferences.storedPreferences[0].largeMetrics)
            }
    }
}

struct UnitsView_Previews: PreviewProvider {
    static var previews: some View {
        UnitsView()
    }
}

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
        HStack {
            Text("Prefered Units")
            Spacer()
            Picker("Prefered Units", selection: $preferences.storedPreferences[0].metricsChoiceConverted) {
                Text("Imperial").tag(UnitsChoice.imperial)
                Text("Metric").tag(UnitsChoice.metric)
                    .onChange(of: preferences.storedPreferences[0].metricsChoiceConverted) { value in
                        persistenceController.updateUserPreferences(
                            existingPreferences: preferences.storedPreferences[0],
                            unitsChoice: preferences.storedPreferences[0].metricsChoiceConverted,
                            displayingMetrics: preferences.storedPreferences[0].displayingMetrics,
                            colourChoice: preferences.storedPreferences[0].colourChoiceConverted,
                            largeMetrics: preferences.storedPreferences[0].largeMetrics,
                            sortChoice: preferences.storedPreferences[0].sortingChoiceConverted,
                            deletionConfirmation: preferences.storedPreferences[0].deletionConfirmation,
                            deletionEnabled: preferences.storedPreferences[0].deletionEnabled,
                            iconIndex: preferences.storedPreferences[0].iconIndex,
                            namedRoutes: preferences.storedPreferences[0].namedRoutes,
                            selectedRoute: preferences.storedPreferences[0].selectedRoute)
                    }
            }
            .frame(maxWidth: 150)
            .pickerStyle(SegmentedPickerStyle())
        }
        Toggle("Display Metrics on Map", isOn: $preferences.storedPreferences[0].displayingMetrics)
            .onChange(of: preferences.storedPreferences[0].displayingMetrics) { value in
                persistenceController.updateUserPreferences(
                    existingPreferences: preferences.storedPreferences[0],
                    unitsChoice: preferences.storedPreferences[0].metricsChoiceConverted,
                    displayingMetrics: preferences.storedPreferences[0].displayingMetrics,
                    colourChoice: preferences.storedPreferences[0].colourChoiceConverted,
                    largeMetrics: preferences.storedPreferences[0].largeMetrics,
                    sortChoice: preferences.storedPreferences[0].sortingChoiceConverted,
                    deletionConfirmation: preferences.storedPreferences[0].deletionConfirmation,
                    deletionEnabled: preferences.storedPreferences[0].deletionEnabled,
                    iconIndex: preferences.storedPreferences[0].iconIndex,
                    namedRoutes: preferences.storedPreferences[0].namedRoutes,
                    selectedRoute: preferences.storedPreferences[0].selectedRoute)
            }
        Toggle("Large Metrics View", isOn: $preferences.storedPreferences[0].largeMetrics)
            .onChange(of: preferences.storedPreferences[0].largeMetrics) { value in
                persistenceController.updateUserPreferences(
                    existingPreferences: preferences.storedPreferences[0],
                    unitsChoice: preferences.storedPreferences[0].metricsChoiceConverted,
                    displayingMetrics: preferences.storedPreferences[0].displayingMetrics,
                    colourChoice: preferences.storedPreferences[0].colourChoiceConverted,
                    largeMetrics: preferences.storedPreferences[0].largeMetrics,
                    sortChoice: preferences.storedPreferences[0].sortingChoiceConverted,
                    deletionConfirmation: preferences.storedPreferences[0].deletionConfirmation,
                    deletionEnabled: preferences.storedPreferences[0].deletionEnabled,
                    iconIndex: preferences.storedPreferences[0].iconIndex,
                    namedRoutes: preferences.storedPreferences[0].namedRoutes,
                    selectedRoute: preferences.storedPreferences[0].selectedRoute)
            }
    }
}

struct UnitsView_Previews: PreviewProvider {
    static var previews: some View {
        UnitsView()
    }
}

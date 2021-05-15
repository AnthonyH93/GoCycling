//
//  CyclingHistorySettingsView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-05-06.
//

import SwiftUI

struct CyclingHistorySettingsView: View {
    let persistenceController = PersistenceController.shared
    
    @EnvironmentObject var preferences: PreferencesStorage
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    var body: some View {
        Toggle("Route Categorization Enabled", isOn: $preferences.storedPreferences[0].namedRoutes)
            .onChange(of: preferences.storedPreferences[0].namedRoutes) { value in
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
                    namedRoutes: preferences.storedPreferences[0].namedRoutes)
            }
        Toggle("Deletion Enabled", isOn: $preferences.storedPreferences[0].deletionEnabled)
            .onChange(of: preferences.storedPreferences[0].deletionEnabled) { value in
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
                    namedRoutes: preferences.storedPreferences[0].namedRoutes)
            }
        Toggle("Deletion Confirmation Alert", isOn: $preferences.storedPreferences[0].deletionConfirmation)
            .onChange(of: preferences.storedPreferences[0].deletionConfirmation) { value in
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
                    namedRoutes: preferences.storedPreferences[0].namedRoutes)
            }
    }
}

struct CyclingHistorySettingsView_Previews: PreviewProvider {
    static var previews: some View {
        CyclingHistorySettingsView()
    }
}

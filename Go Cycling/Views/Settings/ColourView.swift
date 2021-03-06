//
//  ColourView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-17.
//

import SwiftUI

struct ColourView: View {
    let persistenceController = PersistenceController.shared
    
    @EnvironmentObject var preferences: PreferencesStorage
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    var body: some View {
        Picker("Colour", selection: $preferences.storedPreferences[0].colourChoiceConverted) {
            Text("Red").tag(ColourChoice.red)
            Text("Orange").tag(ColourChoice.orange)
            Text("Yellow").tag(ColourChoice.yellow)
            Text("Green").tag(ColourChoice.green)
            Text("Blue").tag(ColourChoice.blue)
            Text("Indigo").tag(ColourChoice.indigo)
            Text("Violet").tag(ColourChoice.violet)
                .navigationBarTitle("Choose your Colour", displayMode: .inline)
                .onChange(of: preferences.storedPreferences[0].colourChoiceConverted) { value in
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
}

struct ColourView_Previews: PreviewProvider {
    static var previews: some View {
        ColourView()
    }
}

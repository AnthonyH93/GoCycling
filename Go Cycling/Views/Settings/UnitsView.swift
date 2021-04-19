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
        Toggle("Use Metric Units", isOn: $preferences.storedPreferences[0].usingMetric)
            .onChange(of: preferences.storedPreferences[0].usingMetric) { value in
                persistenceController.storeUserPreferences(
                    usingMetric: preferences.storedPreferences[0].usingMetric,
                    displayingMetrics: preferences.storedPreferences[0].displayingMetrics,
                    colourChoice: preferences.storedPreferences[0].colourChoiceConverted)
            }
        Toggle("Display Metrics on Map", isOn: $preferences.storedPreferences[0].displayingMetrics)
            .onChange(of: preferences.storedPreferences[0].displayingMetrics) { value in
                persistenceController.storeUserPreferences(
                    usingMetric: preferences.storedPreferences[0].usingMetric,
                    displayingMetrics: preferences.storedPreferences[0].displayingMetrics,
                    colourChoice: preferences.storedPreferences[0].colourChoiceConverted)
            }
    }
}

struct UnitsView_Previews: PreviewProvider {
    static var previews: some View {
        UnitsView()
    }
}

//
//  UnitsView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-18.
//

import SwiftUI

struct UnitsView: View {
    @EnvironmentObject var preferences: PreferencesStorage
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    var body: some View {
        Toggle("Use Metric Units", isOn: $preferences.storedPreferences[0].usingMetric)
            .onChange(of: preferences.storedPreferences[0].usingMetric) { value in
                let newPreferences = UserPreferences(context: managedObjectContext)
                newPreferences.usingMetric = preferences.storedPreferences[0].usingMetric
                newPreferences.displayingMetrics = preferences.storedPreferences[0].displayingMetrics
                newPreferences.colourChoice = preferences.storedPreferences[0].colourChoiceConverted.rawValue
                do {
                    try managedObjectContext.save()
                    print("Preferences saved")
                } catch {
                    print(error.localizedDescription)
                }
            }
        Toggle("Display Metrics on Map", isOn: $preferences.storedPreferences[0].displayingMetrics)
            .onChange(of: preferences.storedPreferences[0].displayingMetrics) { value in
                let newPreferences = UserPreferences(context: managedObjectContext)
                newPreferences.usingMetric = preferences.storedPreferences[0].usingMetric
                newPreferences.displayingMetrics = preferences.storedPreferences[0].displayingMetrics
                newPreferences.colourChoice = preferences.storedPreferences[0].colourChoiceConverted.rawValue
                do {
                    try managedObjectContext.save()
                    print("Preferences saved")
                } catch {
                    print(error.localizedDescription)
                }
            }
    }
}

struct UnitsView_Previews: PreviewProvider {
    static var previews: some View {
        UnitsView()
    }
}

//
//  ColourView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-17.
//

import SwiftUI

struct ColourView: View {
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
}

struct ColourView_Previews: PreviewProvider {
    static var previews: some View {
        ColourView()
    }
}

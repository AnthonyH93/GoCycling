//
//  ColourView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-17.
//

import SwiftUI

struct ColourView: View {
    let persistenceController = PersistenceController.shared
    
    @EnvironmentObject var preferences: Preferences
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    var body: some View {
        // The picker view within a form changed in iOS 16
        if #available(iOS 16.0, *) {
            Picker("Colour", selection: $preferences.colourChoiceConverted) {
                Text("Red").tag(ColourChoice.red)
                Text("Orange").tag(ColourChoice.orange)
                Text("Yellow").tag(ColourChoice.yellow)
                Text("Green").tag(ColourChoice.green)
                Text("Blue").tag(ColourChoice.blue)
                Text("Indigo").tag(ColourChoice.indigo)
                Text("Violet").tag(ColourChoice.violet)
                    .navigationBarTitle("Choose your Colour", displayMode: .inline)
                    .onChange(of: preferences.colourChoiceConverted) { _ in
                        preferences.updateStringPreference(preference: CustomizablePreferences.colour, value: preferences.colourChoice)
                    }
            }
            // Use the navigation link picker style (how it looked before iOS 16)
            .pickerStyle(.navigationLink)
        }
        else {
            Picker("Colour", selection: $preferences.colourChoiceConverted) {
                Text("Red").tag(ColourChoice.red)
                Text("Orange").tag(ColourChoice.orange)
                Text("Yellow").tag(ColourChoice.yellow)
                Text("Green").tag(ColourChoice.green)
                Text("Blue").tag(ColourChoice.blue)
                Text("Indigo").tag(ColourChoice.indigo)
                Text("Violet").tag(ColourChoice.violet)
                    .navigationBarTitle("Choose your Colour", displayMode: .inline)
                    .onChange(of: preferences.colourChoiceConverted) { _ in
                        preferences.updateStringPreference(preference: CustomizablePreferences.colour, value: preferences.colourChoice)
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

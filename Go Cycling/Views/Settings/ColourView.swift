//
//  ColourView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-17.
//

import SwiftUI

struct ColourView: View {
    let persistenceController = PersistenceController.shared
    
    @EnvironmentObject var newPreferences: Preferences
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    var body: some View {
        Picker("Colour", selection: $newPreferences.colourChoiceConverted) {
            Text("Red").tag(ColourChoice.red)
            Text("Orange").tag(ColourChoice.orange)
            Text("Yellow").tag(ColourChoice.yellow)
            Text("Green").tag(ColourChoice.green)
            Text("Blue").tag(ColourChoice.blue)
            Text("Indigo").tag(ColourChoice.indigo)
            Text("Violet").tag(ColourChoice.violet)
                .navigationBarTitle("Choose your Colour", displayMode: .inline)
                .onChange(of: newPreferences.colourChoiceConverted) { _ in
                    newPreferences.updateStringPreference(preference: CustomizablePreferences.colour, value: newPreferences.colourChoice)
                }
        }
    }
}

struct ColourView_Previews: PreviewProvider {
    static var previews: some View {
        ColourView()
    }
}

//
//  ColourView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-17.
//

import SwiftUI

struct ColourView: View {
    @EnvironmentObject var preferences: UserPreferences
    @State private var selectedColour = Colours.blue

    var body: some View {
        Picker("Colour", selection: $selectedColour) {
            Text("Red").tag(Colours.red)
            Text("Orange").tag(Colours.orange)
            Text("Yellow").tag(Colours.yellow)
            Text("Green").tag(Colours.green)
            Text("Blue").tag(Colours.blue)
            Text("Indigo").tag(Colours.indigo)
            Text("Violet").tag(Colours.violet)
                .navigationBarTitle("Choose your Colour", displayMode: .inline)
        }
    }
}

enum Colours: String, CaseIterable, Identifiable {
    case red
    case orange
    case yellow
    case green
    case blue
    case indigo
    case violet

    var id: String { self.rawValue }
}

struct ColourView_Previews: PreviewProvider {
    static var previews: some View {
        ColourView()
    }
}

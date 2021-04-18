//
//  ColourView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-17.
//

import SwiftUI

struct ColourView: View {
    @EnvironmentObject var preferences: UserPreferences

    var body: some View {
        VStack {
            ColorPicker("Colour Preference", selection: $preferences.colour, supportsOpacity: false)
                .padding(.all, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(preferences.colour)
    }
}

struct ColourView_Previews: PreviewProvider {
    static var previews: some View {
        ColourView()
    }
}

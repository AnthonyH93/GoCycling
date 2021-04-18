//
//  SettingsView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-17.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var preferences: UserPreferences
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    ColourView()
                }
                .navigationBarTitle("Settings", displayMode: .inline)
            }
            .navigationBarTitle(Text("Settings"))
        }
    }
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

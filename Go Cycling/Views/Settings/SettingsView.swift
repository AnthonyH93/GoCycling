//
//  SettingsView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-17.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var preferences: UserPreferences
    @State private var favoriteColor = 0

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Customization")) {
                    ColourView()
                }
                .navigationBarTitle("Settings", displayMode: .inline)
                Section(header: Text("Units")) {
                    UnitsView()
                }
                Section(header: Text("About the app")) {
                    AboutApp()
                }
            }
            .navigationBarTitle(Text("Settings"))
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

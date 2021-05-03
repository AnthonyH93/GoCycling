//
//  SettingsView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-17.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var cyclingStatus: CyclingStatus

    var body: some View {
        NavigationView {
            VStack {
                if (cyclingStatus.isCycling) {
                    Text("Certain sections are disabled while cycling is in progress. Please end the current cycling session to enable editing of all settings.")
                        .padding(.all, 10)
                }
                Form {
                    Section(header: Text("Customization")) {
                        ColourView()
                        ChangeAppIconView().environmentObject(IconNames())
                    }
                    .disabled(cyclingStatus.isCycling)
                    .navigationBarTitle("Settings", displayMode: .inline)
                    Section(header: Text("Cycling Metrics")) {
                        UnitsView()
                    }
                    .disabled(cyclingStatus.isCycling)
                    Section(header: Text("About the app")) {
                        AboutApp()
                    }
                }
                .navigationBarTitle(Text("Settings"))
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct DisabledTextView: View {
    var body: some View {
        Text("This section is disabled while a cycling session is in progress. End the current cycling session to edit these settings.")
    }
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

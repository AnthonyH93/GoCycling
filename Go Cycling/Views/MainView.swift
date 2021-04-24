//
//  MainView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-03-14.
//

import SwiftUI
import CoreData

struct MainView: View {
    @EnvironmentObject var preferences: PreferencesStorage
    
    var body: some View {
        TabView {
            CycleView()
                .tabItem {
                    Label("Cycle", systemImage: "bicycle")
                }
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "arrow.clockwise.heart")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .accentColor(Color(UserPreferences.convertColourChoiceToUIColor(colour: preferences.storedPreferences[0].colourChoiceConverted)))
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

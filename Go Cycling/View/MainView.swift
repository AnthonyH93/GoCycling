//
//  MainView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-03-14.
//

import SwiftUI
import CoreData

struct MainView: View {
    @EnvironmentObject var preferences: Preferences
    
    init() {
        /* For iOS 15 */
        if #available(iOS 15, *) {
            UITableView.appearance().sectionHeaderTopPadding = 0
        }
    }
    
    var themeColor: Color {
        Color(UserPreferences.convertColourChoiceToUIColor(colour: preferences.colourChoiceConverted))
    }

    var body: some View {
        let tabs = TabView {
            CycleView()
                .tabItem { Label("Cycle", systemImage: "bicycle") }
            HistoryView()
                .tabItem { Label("History", systemImage: "clock.arrow.circlepath") }
            StatisticsView()
                .tabItem { Label("Statistics", systemImage: "chart.bar.xaxis") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gear") }
        }
        .accentColor(themeColor)

        if #available(iOS 15, *) {
            // .tint() is the only reliable way to colour Toggle switches on iOS 15+
            tabs.tint(themeColor)
        } else {
            // iOS 14: use UIAppearance, set before and on change
            tabs
                .onAppear {
                    UISwitch.appearance().onTintColor = UserPreferences.convertColourChoiceToUIColor(colour: preferences.colourChoiceConverted)
                }
                .onChange(of: preferences.colourChoice) { _ in
                    UISwitch.appearance().onTintColor = UserPreferences.convertColourChoiceToUIColor(colour: preferences.colourChoiceConverted)
                }
                .onChange(of: preferences.customColourHex) { _ in
                    UISwitch.appearance().onTintColor = UserPreferences.convertColourChoiceToUIColor(colour: preferences.colourChoiceConverted)
                }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

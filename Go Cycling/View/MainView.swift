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
    
    var themeUIColor: UIColor {
        UserPreferences.convertColourChoiceToUIColor(colour: preferences.colourChoiceConverted)
    }

    var body: some View {
        TabView {
            CycleView()
                .tabItem {
                    Label("Cycle", systemImage: "bicycle")
                }

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
            StatisticsView()
                .tabItem {
                    Label("Statistics", systemImage: "chart.bar.xaxis")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .accentColor(Color(themeUIColor))
        .onAppear {
            UISwitch.appearance().onTintColor = themeUIColor
        }
        .onChange(of: preferences.colourChoice) { _ in
            UISwitch.appearance().onTintColor = themeUIColor
        }
        .onChange(of: preferences.customColourHex) { _ in
            UISwitch.appearance().onTintColor = themeUIColor
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

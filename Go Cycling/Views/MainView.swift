//
//  MainView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-03-14.
//

import SwiftUI

struct MainView: View {
    @StateObject var preferences = UserPreferences(colour: ColourChoice.blue, usingMetric: true, displayingMetrics: true)
    
    var body: some View {
        TabView {
            CycleView()
                .tabItem {
                    Label("Cycle", systemImage: "bicycle")
                }
            
            StatisticsView()
                .tabItem {
                    Label("Statistics", systemImage: "arrow.clockwise.heart")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .environmentObject(preferences)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

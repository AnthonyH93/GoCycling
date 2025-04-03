//
//  ActivityRewardsView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-08-31.
//

import SwiftUI

struct ActivityAwardsView: View {
    @StateObject var activityAwardsViewModel = ActivityAwardsViewModel()
    
    @EnvironmentObject var preferences: Preferences
    
    @State var showingNewIconAlert = false
    
    // Access singleton TelemetryManager class object
    let telemetryManager = TelemetryManager.sharedTelemetryManager
    let telemetryTab = TelemetryTab.Statistics

    var body: some View {
        Section (header: Text(RecordsFormatting.headerStrings[2]), footer: Text(RecordsFormatting.footerStrings[1])) {
            VStack {
                ForEach (0..<Records.awardValues.count, id: \.self) { index in
                    SingleActivityAwardView(progress: activityAwardsViewModel.progressValues[index], iconName: activityAwardsViewModel.getAwardName(index: index, usingMetric: preferences.usingMetric), progressString: activityAwardsViewModel.progressStrings[index], medal: activityAwardsViewModel.medalOrder[index])
                }
            }
        }
        // Alert to let the user know that they just unlocked a new icon
        .alert(isPresented: $showingNewIconAlert) {
            Alert(
                title: Text("Congratulations! You".capitalized + " have unlocked a new app icon! 🎉"),
                message: Text("Navigate".capitalized +  " to the settings tab to enable your new app icon."),
                dismissButton: .default(Text("OK")) {
                    activityAwardsViewModel.resetAlert()
                }
            )
        }
        .onAppear {
            if (activityAwardsViewModel.alertForNewIcon) {
                showingNewIconAlert = true
                
                telemetryManager.sendCyclingSignal(
                    tab: telemetryTab,
                    action: TelemetryCyclingAction.AwardUnlocked
                )
            }
        }
    }
}

struct ActivityAwardsView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityAwardsView()
    }
}

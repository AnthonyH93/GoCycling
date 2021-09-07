//
//  ActivityRewardsView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-08-31.
//

import SwiftUI

struct ActivityAwardsView: View {
    @StateObject var activityAwardsViewModel = ActivityAwardsViewModel()
    
    @EnvironmentObject var preferences: PreferencesStorage
    
    @State var showingNewIconAlert = false

    var body: some View {
        Section (header: Text(RecordsFormatting.headerStrings[2]), footer: Text(RecordsFormatting.footerStrings[1])) {
            VStack {
                ForEach (0..<Records.awardValues.count) { index in
                    SingleActivityAwardView(progress: activityAwardsViewModel.progressValues[index], iconName: activityAwardsViewModel.getAwardName(index: index, usingMetric: preferences.storedPreferences[0].usingMetric), progressString: activityAwardsViewModel.progressStrings[index], medal: activityAwardsViewModel.medalOrder[index])
                }
            }
        }
        // Alert to let the user know that they just unlocked a new icon
        .alert(isPresented: $showingNewIconAlert) {
            Alert(title: Text("Congratulations! You have unlocked a new app icon!"),
                  message: Text("Navigate to the settings tab to enable your new app icon."),
                  dismissButton: .default(Text("OK")) {
                    activityAwardsViewModel.resetAlert()
                  }
            )
        }
        .onAppear {
            if (activityAwardsViewModel.alertForNewIcon) {
                showingNewIconAlert = true
            }
        }
    }
}

struct ActivityAwardsView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityAwardsView()
    }
}

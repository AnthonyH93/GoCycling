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

    var body: some View {
        Section (header: Text(RecordsFormatting.headerStrings[2]), footer: Text(RecordsFormatting.footerStrings[1])) {
            VStack {
                ForEach (0..<Records.awardValues.count) { index in
                    SingleActivityAwardView(progress: activityAwardsViewModel.progressValues[index], iconName: activityAwardsViewModel.getAwardName(index: index, usingMetric: preferences.storedPreferences[0].usingMetric), progressString: activityAwardsViewModel.progressStrings[index], medal: activityAwardsViewModel.medalOrder[index])
                }
            }
        }
    }
}

struct ActivityAwardsView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityAwardsView()
    }
}

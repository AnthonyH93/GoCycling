//
//  ActivityRewardsView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-08-31.
//

import SwiftUI

struct ActivityAwardsView: View {
    
    @StateObject var activityAwardsViewModel = ActivityAwardsViewModel()
        
    let persistenceController = PersistenceController.shared
    
    @EnvironmentObject var records: RecordsStorage
    @EnvironmentObject var preferences: PreferencesStorage
    
    @Environment(\.managedObjectContext) private var managedObjectContext

    var body: some View {
        Section (header: Text(RecordsFormatting.headerStrings[2]), footer: Text(RecordsFormatting.footerStrings[1])) {
            VStack {
                SingleActivityAwardView(progress: activityAwardsViewModel.progressValues[0], iconName: activityAwardsViewModel.getAwardName(index: 0, usingMetric: preferences.storedPreferences[0].usingMetric), progressString: activityAwardsViewModel.progressStrings[0], medal: Medal.bronze)
                SingleActivityAwardView(progress: activityAwardsViewModel.progressValues[1], iconName: activityAwardsViewModel.getAwardName(index: 1, usingMetric: preferences.storedPreferences[0].usingMetric), progressString: activityAwardsViewModel.progressStrings[1], medal: Medal.silver)
                SingleActivityAwardView(progress: activityAwardsViewModel.progressValues[2], iconName: activityAwardsViewModel.getAwardName(index: 2, usingMetric: preferences.storedPreferences[0].usingMetric), progressString: activityAwardsViewModel.progressStrings[2], medal: Medal.gold)
                SingleActivityAwardView(progress: activityAwardsViewModel.progressValues[3], iconName: activityAwardsViewModel.getAwardName(index: 3, usingMetric: preferences.storedPreferences[0].usingMetric), progressString: activityAwardsViewModel.progressStrings[3], medal: Medal.bronze)
                SingleActivityAwardView(progress: activityAwardsViewModel.progressValues[4], iconName: activityAwardsViewModel.getAwardName(index: 4, usingMetric: preferences.storedPreferences[0].usingMetric), progressString: activityAwardsViewModel.progressStrings[4], medal: Medal.silver)
                SingleActivityAwardView(progress: activityAwardsViewModel.progressValues[5], iconName: activityAwardsViewModel.getAwardName(index: 5, usingMetric: preferences.storedPreferences[0].usingMetric), progressString: activityAwardsViewModel.progressStrings[5], medal: Medal.gold)
            }
        }
    }
}

struct ActivityAwardsView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityAwardsView()
    }
}

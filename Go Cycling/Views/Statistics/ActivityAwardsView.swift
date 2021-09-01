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
    
    @EnvironmentObject var preferences: PreferencesStorage
    @EnvironmentObject var records: RecordsStorage
    
    @Environment(\.managedObjectContext) private var managedObjectContext
    var body: some View {
        Section (header: Text(RecordsFormatting.headerStrings[2]), footer: Text(RecordsFormatting.footerStrings[1])) {
            VStack {
                SingleActivityAwardView(progress: activityAwardsViewModel.progressValues[0], iconName: "Name", progressString: "Progress", medal: Medal.bronze)
                SingleActivityAwardView(progress: activityAwardsViewModel.progressValues[1], iconName: "Name", progressString: "Progress", medal: Medal.silver)
                SingleActivityAwardView(progress: activityAwardsViewModel.progressValues[2], iconName: "Name", progressString: "Progress", medal: Medal.gold)
                SingleActivityAwardView(progress: activityAwardsViewModel.progressValues[3], iconName: "Name", progressString: "Progress", medal: Medal.bronze)
                SingleActivityAwardView(progress: activityAwardsViewModel.progressValues[4], iconName: "Name", progressString: "Progress", medal: Medal.silver)
                SingleActivityAwardView(progress: activityAwardsViewModel.progressValues[5], iconName: "Name", progressString: "Progress", medal: Medal.gold)
            }
        }
    }
}

struct ActivityAwardsView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityAwardsView()
    }
}

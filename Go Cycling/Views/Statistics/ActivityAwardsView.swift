//
//  ActivityRewardsView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-08-31.
//

import SwiftUI

struct ActivityAwardsView: View {
    let persistenceController = PersistenceController.shared
    
    @EnvironmentObject var preferences: PreferencesStorage
    @EnvironmentObject var records: RecordsStorage
    
    @Environment(\.managedObjectContext) private var managedObjectContext
    var body: some View {
        Section (header: Text(RecordsFormatting.headerStrings[2]), footer: Text(RecordsFormatting.footerStrings[1])) {
            VStack {
                SingleActivityAwardView(progress: 0.7, iconName: "Name", progressString: "Progress", medal: Medal.bronze)
                SingleActivityAwardView(progress: 0.7, iconName: "Name", progressString: "Progress", medal: Medal.silver)
                SingleActivityAwardView(progress: 0.7, iconName: "Name", progressString: "Progress", medal: Medal.gold)
            }
        }
    }
}

struct ActivityAwardsView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityAwardsView()
    }
}

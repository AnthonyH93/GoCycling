//
//  ActivityRewardsView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-08-31.
//

import SwiftUI

struct ActivityAwardsView: View {
    var body: some View {
        Section (header: Text(RecordsFormatting.headerStrings[2]), footer: Text(RecordsFormatting.footerStrings[1])) {
            VStack {
                SingleActivityAwardView()
                SingleActivityAwardView()
                SingleActivityAwardView()
            }
        }
    }
}

struct ActivityAwardsView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityAwardsView()
    }
}

//
//  StatisticsView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-08-23.
//

import SwiftUI

struct StatisticsView: View {
    var body: some View {
        NavigationView {
            Form {
                CyclingChartsView()
                CyclingRecordsView()
                ActivityAwardsView()
            }
            .navigationBarTitle("Cycling Statistics", displayMode: .automatic)
        }
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView()
    }
}

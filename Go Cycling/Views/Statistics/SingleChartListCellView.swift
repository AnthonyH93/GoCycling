//
//  SingleChartDetailView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-09-01.
//

import SwiftUI

struct SingleChartListCellView: View {
    var distances: [Double]
    var times: [Double]
    var numberOfRoutes: [Int]
    var index: Int
    
    @EnvironmentObject var preferences: Preferences
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text(CyclingChartsViewModel.titleStrings[index])
                    .font(.headline)
                    .foregroundColor(Color(UserPreferences.convertColourChoiceToUIColor(colour: preferences.colourChoiceConverted)))
                Spacer()
            }
            HStack {
                Text("Distance Cycled")
                Spacer()
                Text(MetricsFormatting.formatDistance(distance: distances[1], usingMetric: preferences.usingMetric))
                    .bold()
                Text(getPercentageString(index: 0))
                    .bold()
                    .foregroundColor(getPercentageChange(index: 0) >= 0 ? .green : .red)
            }
            HStack {
                Text("Cycling Time")
                Spacer()
                Text(MetricsFormatting.formatTime(time: times[1]))
                    .bold()
                Text(getPercentageString(index: 1))
                    .bold()
                    .foregroundColor(getPercentageChange(index: 1) >= 0 ? .green : .red)
            }
            HStack {
                Text("Completed Routes")
                Spacer()
                Text("\(numberOfRoutes[1])")
                    .bold()
                Text(getPercentageString(index: 2))
                    .bold()
                    .foregroundColor(getPercentageChange(index: 2) >= 0 ? .green : .red)
            }
        }
    }
    
    func getPercentageChange(index: Int) -> Int {
        if (index == 0) {
            if (distances[0] == 0 && distances[1] == 0) {
                return 0
            }
            let change = distances[0] != 0 ? ((distances[1] - distances[0])/distances[0]) * 100 : 100
            return Int(round(change))
        }
        if (index == 1) {
            if (times[0] == 0 && times[1] == 0) {
                return 0
            }
            let change = times[0] != 0 ? ((times[1] - times[0])/times[0]) * 100 : 100
            return Int(round(change))
        }
        if (index == 2) {
            if (numberOfRoutes[0] == 0 && numberOfRoutes[1] == 0) {
                return 0
            }
            let change = numberOfRoutes[0] != 0 ? ((numberOfRoutes[1] - numberOfRoutes[0])/numberOfRoutes[0]) * 100 : 100
            return change
        }
        return 0
    }
    
    func getPercentageString(index: Int) -> String {
        let percentageChange = getPercentageChange(index: index)
        if (percentageChange == 0) {
            return "0%"
        }
        return "\(percentageChange > 0 ? "↑" : "↓")\(abs(percentageChange) < 999 ? "\(abs(percentageChange))" : ">999")%"
    }
}

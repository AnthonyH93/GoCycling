//
//  BarChartView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-09-02.
//

import SwiftUI

struct BarChartView: View {
    var index: Int
    
    @StateObject var chartViewModel = CyclingChartsViewModel()
    
    @EnvironmentObject var preferences: PreferencesStorage
    
    var body: some View {
        VStack {
            Text(CyclingChartsViewModel.titleStrings[index])
                .bold()
            // Chart
            GeometryReader { geometry in
                VStack {
                    HStack {
                        ForEach (0..<chartViewModel.pastWeekDistances.count, id: \.self) { index in
                            BarChartCellView(value: chartViewModel.pastWeekDistancesNormalized[index], barColor: Color(UserPreferences.convertColourChoiceToUIColor(colour: preferences.storedPreferences[0].colourChoiceConverted)))
                                .animation(.spring())
                                .padding(.top)
                        }
                    }
                }
            }
        }
        .padding()
    }
}

//struct BarChartView_Previews: PreviewProvider {
//    static var previews: some View {
//        BarChartView()
//    }
//}

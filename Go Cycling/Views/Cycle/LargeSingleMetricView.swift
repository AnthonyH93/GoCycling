//
//  LargeSingleMetricView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-25.
//

import SwiftUI

struct LargeSingleMetricView: View {
    let metricName: String
    let metricText: String
    let metricUnits: String
    
    var body: some View {
        VStack(alignment: .center) {
            Text(metricName)
            Text(metricText)
                .font(.title)
            Text(metricUnits)
                .font(.title2)
        }
        .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
    }
}

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
                .minimumScaleFactor(0.3)
                .lineLimit(1)
            Text(metricText)
                .font(.title)
                .minimumScaleFactor(0.3)
                .lineLimit(1)
            Text(metricUnits)
                .font(.title2)
                .minimumScaleFactor(0.3)
                .lineLimit(1)
        }
        .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
    }
}

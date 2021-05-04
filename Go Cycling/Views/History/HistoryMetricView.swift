//
//  HistoryMetricView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-24.
//

import SwiftUI

struct HistoryMetricView: View {
    let systemImageString: String
    let metricName: String
    let metricText: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            HStack (spacing: 10) {
                Text(metricName)
                    .minimumScaleFactor(0.3)
                    .lineLimit(1)
                Image(systemName: systemImageString)
            }
            Text(metricText)
                .font(.title)
                .minimumScaleFactor(0.3)
                .lineLimit(1)
        }
    }
}

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
        VStack(alignment: .center, spacing: 4) {
            Image(systemName: systemImageString)
                .font(.title3)
                .foregroundColor(.accentColor)
            Text(metricName)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(metricText)
                .font(.headline)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.secondarySystemFill))
        )
    }
}

//
//  SpeedTrendDetailView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2026-05-23.
//

import SwiftUI

@available(iOS 16, *)
struct SpeedTrendDetailView: View {
    @State private var selectedPeriod: ChartPeriod = .oneMonth
    @StateObject private var viewModel = StatisticsChartsViewModel(period: .oneMonth)

    @EnvironmentObject var preferences: Preferences

    let telemetryManager = TelemetryManager.sharedTelemetryManager

    var themeColor: Color {
        Color(UserPreferences.convertColourChoiceToUIColor(colour: preferences.colourChoiceConverted))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Summary header
            summaryHeader
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 8)

            // Chart fills all remaining space
            SpeedTrendChart(
                speedPoints: viewModel.speedPoints,
                themeColor: themeColor,
                usingMetric: preferences.usingMetric
            )
            .padding(.horizontal)
            .frame(maxHeight: .infinity)

            Divider()

            // Period picker
            periodPicker
                .padding(.horizontal)
                .padding(.vertical, 10)
        }
        .navigationBarTitle("Speed Trend", displayMode: .inline)
        .onAppear {
            viewModel.loadData(for: selectedPeriod)
            telemetryManager.sendCyclingSignal(tab: .Statistics, action: .SpeedTrendView)
        }
        .onChange(of: selectedPeriod) { newPeriod in
            viewModel.loadData(for: newPeriod)
        }
    }

    private var summaryHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(selectedPeriod.displayName)
                .font(.subheadline)
                .foregroundColor(.secondary)
            if viewModel.avgCurrentSpeed > 0 {
                Text(MetricsFormatting.formatSingleSpeed(speed: viewModel.avgCurrentSpeed, usingMetric: preferences.usingMetric))
                    .font(.title2.bold())
                Text("Average speed")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("No routes")
                    .font(.title2.bold())
                    .foregroundColor(.secondary)
            }
        }
    }

    private var periodPicker: some View {
        HStack(spacing: 0) {
            ForEach(ChartPeriod.allCases) { period in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedPeriod = period
                    }
                } label: {
                    Text(period.label)
                        .font(.system(size: 13, weight: selectedPeriod == period ? .bold : .regular))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(selectedPeriod == period ? themeColor.opacity(0.15) : Color.clear)
                        )
                        .foregroundColor(selectedPeriod == period ? themeColor : .primary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
        )
    }
}

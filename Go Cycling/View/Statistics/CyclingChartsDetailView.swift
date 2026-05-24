//
//  CyclingChartsDetailView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2026-05-23.
//

import SwiftUI

@available(iOS 16, *)
struct CyclingChartsDetailView: View {
    @AppStorage("lastChartPeriod") private var lastChartPeriodRaw: Int = ChartPeriod.oneWeek.rawValue

    @State private var selectedPeriod: ChartPeriod = .oneWeek
    @State private var selectedMetric: ChartMetric = .distance
    @State private var showPrevious: Bool = false
    @StateObject private var viewModel = StatisticsChartsViewModel(period: .oneWeek)

    @EnvironmentObject var preferences: Preferences

    let telemetryManager = TelemetryManager.sharedTelemetryManager

    var themeColor: Color {
        Color(UserPreferences.convertColourChoiceToUIColor(colour: preferences.colourChoiceConverted))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Metric picker
            Picker("Metric", selection: $selectedMetric) {
                ForEach(ChartMetric.allCases) { metric in
                    Text(metric.label).tag(metric)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 8)

            // Line chart — fills all remaining vertical space
            CyclingBarChart(
                points: viewModel.currentPoints,
                previousPoints: viewModel.previousPoints,
                showPrevious: showPrevious,
                period: selectedPeriod,
                metric: selectedMetric,
                themeColor: themeColor,
                usingMetric: preferences.usingMetric
            )
            .padding(.horizontal)
            .frame(maxHeight: .infinity)
            .id(selectedPeriod.rawValue)

            Divider()

            // vs Previous Period toggle
            HStack {
                Text("vs Previous Period")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Toggle("", isOn: $showPrevious)
                    .labelsHidden()
                    .tint(themeColor)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)

            Divider()

            // Period picker
            periodPicker
                .padding(.horizontal)
                .padding(.vertical, 10)
        }
        .navigationBarTitle(selectedPeriod.displayName, displayMode: .inline)
        .onAppear {
            let period = ChartPeriod(rawValue: lastChartPeriodRaw) ?? .oneWeek
            selectedPeriod = period
            viewModel.loadData(for: period)
            telemetryManager.sendCyclingSignal(tab: .Statistics, action: telemetryAction(for: period))
        }
        .onChange(of: selectedPeriod) { newPeriod in
            lastChartPeriodRaw = newPeriod.rawValue
            viewModel.loadData(for: newPeriod)
            telemetryManager.sendCyclingSignal(tab: .Statistics, action: telemetryAction(for: newPeriod))
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

    private func telemetryAction(for period: ChartPeriod) -> TelemetryCyclingAction {
        switch period {
        case .oneWeek:     return .OneWeek
        case .oneMonth:    return .OneMonth
        case .threeMonths: return .ThreeMonths
        case .sixMonths:   return .SixMonths
        case .yearToDate:  return .YearToDate
        case .oneYear:     return .OneYear
        }
    }
}

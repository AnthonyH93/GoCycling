//
//  ActivityHeatmapDetailView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2026-05-23.
//

import SwiftUI

@available(iOS 16, *)
struct ActivityHeatmapDetailView: View {
    private let availablePeriods: [ChartPeriod] = [.threeMonths, .sixMonths, .yearToDate, .oneYear]

    @State private var selectedPeriod: ChartPeriod = .yearToDate
    @AppStorage("lastHeatmapMetric") private var selectedMetricRaw: Int = ChartMetric.routes.rawValue
    private var selectedMetric: ChartMetric {
        get { ChartMetric(rawValue: selectedMetricRaw) ?? .routes }
        set { selectedMetricRaw = newValue.rawValue }
    }
    @StateObject private var viewModel = StatisticsChartsViewModel(period: .yearToDate)

    @EnvironmentObject var preferences: Preferences

    let telemetryManager = TelemetryManager.sharedTelemetryManager

    var themeColor: Color {
        Color(UserPreferences.convertColourChoiceToUIColor(colour: preferences.colourChoiceConverted))
    }

    // Map the selected metric to the right [Date: Double] dictionary
    var activeValueData: [Date: Double] {
        switch selectedMetric {
        case .routes:   return viewModel.heatmapData.mapValues { Double($0) }
        case .distance: return viewModel.heatmapDistanceData
        case .time:     return viewModel.heatmapTimeData
        }
    }

    var body: some View {
        ActivityHeatmapChart(
            valueData: activeValueData,
            metric: selectedMetric,
            period: selectedPeriod,
            themeColor: themeColor,
            usingMetric: preferences.usingMetric
        )
        .padding(.horizontal)
        .safeAreaInset(edge: .top, spacing: 0) {
            VStack(spacing: 0) {
                Picker("Metric", selection: Binding(
                    get: { selectedMetric },
                    set: { selectedMetricRaw = $0.rawValue }
                )) {
                    ForEach(ChartMetric.allCases) { metric in
                        Text(metric.label).tag(metric)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 8)

                summaryHeader
                    .padding(.horizontal)
                    .padding(.bottom, 8)
            }
            .background(Color(.systemBackground))
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 0) {
                Divider()
                periodPicker
                    .padding(.horizontal)
                    .padding(.vertical, 10)
            }
            .background(Color(.systemBackground))
        }
        .navigationBarTitle("Activity Heatmap", displayMode: .inline)
        .onAppear {
            viewModel.loadData(for: selectedPeriod)
            telemetryManager.sendCyclingSignal(tab: .Statistics, action: .HeatmapView)
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
            Group {
                switch selectedMetric {
                case .routes:
                    Text("\(viewModel.totalCurrentRoutes) \(viewModel.totalCurrentRoutes == 1 ? "route" : "routes")")
                case .distance:
                    Text(MetricsFormatting.formatDistance(distance: viewModel.totalCurrentDistance, usingMetric: preferences.usingMetric))
                case .time:
                    Text(MetricsFormatting.formatTime(time: viewModel.totalCurrentTime))
                }
            }
            .font(.title2.bold())
        }
    }

    private var periodPicker: some View {
        HStack(spacing: 0) {
            ForEach(availablePeriods) { period in
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

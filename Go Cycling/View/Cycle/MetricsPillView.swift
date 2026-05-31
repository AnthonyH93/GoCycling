//
//  MetricsPillView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2026-05-31.
//

import SwiftUI
import CoreLocation

struct MetricsPillView: View {

    @Binding var currentSpeed: CLLocationSpeed?
    @Binding var currentAltitude: CLLocationDistance?
    @Binding var currentDistance: CLLocationDistance

    @EnvironmentObject var preferences: Preferences
    @EnvironmentObject var cyclingStatus: CyclingStatus

    let pillColor: Color

    @State private var isExpanded = true

    var body: some View {
        if preferences.displayingMetrics {
            VStack(spacing: 0) {
                if isExpanded {
                    HStack(spacing: 0) {
                        metricColumn(label: "Speed",
                                     value: MetricsFormatting.formatSpeedWithoutUnits(speed: currentSpeed ?? 0.0, usingMetric: preferences.usingMetric),
                                     units: MetricsFormatting.getSpeedUnits(usingMetric: preferences.usingMetric))
                        Divider().frame(height: 50)
                        metricColumn(label: "Distance",
                                     value: MetricsFormatting.formatDistanceWithoutUnits(distance: cyclingStatus.isCycling ? currentDistance : 0.0, usingMetric: preferences.usingMetric),
                                     units: MetricsFormatting.getDistanceUnits(usingMetric: preferences.usingMetric))
                        Divider().frame(height: 50)
                        metricColumn(label: "Altitude",
                                     value: MetricsFormatting.formatElevationWithoutUnits(elevation: currentAltitude ?? 0.0, usingMetric: preferences.usingMetric),
                                     units: MetricsFormatting.getElevationUnits(usingMetric: preferences.usingMetric))
                    }
                    .transition(.opacity)
                } else {
                    HStack(spacing: 12) {
                        Text("\(MetricsFormatting.formatSpeedWithoutUnits(speed: currentSpeed ?? 0.0, usingMetric: preferences.usingMetric)) \(MetricsFormatting.getSpeedUnits(usingMetric: preferences.usingMetric))")
                        Rectangle()
                            .fill(Color.secondary.opacity(0.6))
                            .frame(width: 1, height: 16)
                        Text("\(MetricsFormatting.formatDistanceWithoutUnits(distance: cyclingStatus.isCycling ? currentDistance : 0.0, usingMetric: preferences.usingMetric)) \(MetricsFormatting.getDistanceUnits(usingMetric: preferences.usingMetric))")
                    }
                    .font(.subheadline.bold())
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .transition(.opacity)
                }

                Capsule()
                    .fill(Color.secondary.opacity(0.5))
                    .frame(width: 28, height: 4)
                    .padding(.bottom, 8)
            }
            .background(pillColor.opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .padding(.horizontal, 12)
            .padding(.top, 10)
            .onTapGesture {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    isExpanded.toggle()
                }
            }
        }
    }

    @ViewBuilder
    private func metricColumn(label: String, value: String, units: String) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            Text(value)
                .font(.title2)
                .bold()
                .minimumScaleFactor(0.3)
                .lineLimit(1)
            Text(units)
                .font(.caption)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
    }
}

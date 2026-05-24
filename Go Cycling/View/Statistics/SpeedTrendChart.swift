//
//  SpeedTrendChart.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2026-05-23.
//

import SwiftUI
import Charts

@available(iOS 16, *)
struct SpeedTrendChart: View {
    let speedPoints: [StatisticsChartsViewModel.SpeedPoint]
    let themeColor: Color
    let usingMetric: Bool

    @State private var selectedDate: Date? = nil

    private func convertedSpeed(_ mps: Double) -> Double {
        usingMetric ? mps * 3.6 : mps * 2.23694
    }

    private var speedUnit: String {
        MetricsFormatting.getSpeedUnits(usingMetric: usingMetric)
    }

    var selectedPoint: StatisticsChartsViewModel.SpeedPoint? {
        guard let selected = selectedDate, !speedPoints.isEmpty else { return nil }
        return speedPoints.min(by: {
            abs($0.date.timeIntervalSince(selected)) < abs($1.date.timeIntervalSince(selected))
        })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Group {
                if let point = selectedPoint {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(formattedDate(point.date))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(MetricsFormatting.formatSingleSpeed(speed: point.speed, usingMetric: usingMetric))
                            .font(.title3.bold())
                    }
                } else {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(" ").font(.caption)
                        Text(" ").font(.title3.bold())
                    }
                }
            }
            .padding(.horizontal, 4)

            if speedPoints.isEmpty {
                Text("No routes in this period")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .frame(maxHeight: .infinity)
            } else {
                Chart(speedPoints) { point in
                    LineMark(
                        x: .value("Date", point.date, unit: .day),
                        y: .value("Speed", convertedSpeed(point.speed))
                    )
                    .foregroundStyle(themeColor)
                    .lineStyle(StrokeStyle(lineWidth: 2))

                    if speedPoints.count <= 20 {
                        PointMark(
                            x: .value("Date", point.date, unit: .day),
                            y: .value("Speed", convertedSpeed(point.speed))
                        )
                        .foregroundStyle(
                            selectedPoint?.id == point.id ? themeColor : themeColor.opacity(0.4)
                        )
                        .symbolSize(selectedPoint?.id == point.id ? 80 : 36)
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel {
                                Text(shortDate(date))
                                    .font(.caption2)
                            }
                        }
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [3]))
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        if let v = value.as(Double.self) {
                            AxisValueLabel {
                                Text("\(Int(v)) \(speedUnit)")
                                    .font(.caption2)
                            }
                        }
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [3]))
                    }
                }
                .chartOverlay { proxy in
                    GeometryReader { geo in
                        Rectangle()
                            .fill(Color.clear)
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { val in
                                        let xPos = val.location.x - geo[proxy.plotAreaFrame].origin.x
                                        if let date: Date = proxy.value(atX: xPos) {
                                            selectedDate = date
                                        }
                                    }
                                    .onEnded { _ in
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                            withAnimation { selectedDate = nil }
                                        }
                                    }
                            )
                    }
                }
                .frame(maxHeight: .infinity)
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d, yyyy"
        return f.string(from: date)
    }

    private func shortDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: date)
    }
}

//
//  CyclingBarChart.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2026-05-23.
//

import SwiftUI
import Charts

@available(iOS 16, *)
struct CyclingBarChart: View {
    let points: [ChartDataPoint]
    let previousPoints: [ChartDataPoint]
    let showPrevious: Bool
    let period: ChartPeriod
    let metric: ChartMetric
    let themeColor: Color
    let usingMetric: Bool

    @State private var selectedBucketDate: Date? = nil

    // Shift previous-period dates forward so they land on the same x-axis as current
    private var shiftedPreviousPoints: [ChartDataPoint] {
        guard showPrevious else { return [] }
        let cal = Calendar.current
        return previousPoints.map { pt in
            ChartDataPoint(
                bucketDate: shiftedDate(pt.bucketDate, calendar: cal),
                distance: pt.distance,
                time: pt.time,
                routes: pt.routes
            )
        }
    }

    private func shiftedDate(_ date: Date, calendar: Calendar) -> Date {
        switch period {
        case .oneWeek:     return calendar.date(byAdding: .day,   value: 7,   to: date) ?? date
        case .oneMonth:    return calendar.date(byAdding: .day,   value: 30,  to: date) ?? date
        case .threeMonths: return calendar.date(byAdding: .day,   value: 91,  to: date) ?? date
        case .sixMonths:   return calendar.date(byAdding: .day,   value: 182, to: date) ?? date
        case .yearToDate:  return calendar.date(byAdding: .year,  value: 1,   to: date) ?? date
        case .oneYear:     return calendar.date(byAdding: .month, value: 12,  to: date) ?? date
        }
    }

    var selectedPoint: ChartDataPoint? {
        guard let selected = selectedBucketDate, !points.isEmpty else { return nil }
        return points.min(by: {
            abs($0.bucketDate.timeIntervalSince(selected)) < abs($1.bucketDate.timeIntervalSince(selected))
        })
    }

    var selectedPreviousPoint: ChartDataPoint? {
        guard showPrevious, let current = selectedPoint else { return nil }
        guard let idx = points.firstIndex(where: { $0.id == current.id }),
              idx < previousPoints.count else { return nil }
        return previousPoints[idx]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Fixed-height callout (3 lines always to prevent layout jump)
            VStack(alignment: .leading, spacing: 2) {
                Text(selectedPoint.map { bucketLabel(for: $0.bucketDate) } ?? " ")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(selectedPoint.map { formattedValue($0) } ?? " ")
                    .font(.title3.bold())
                Text(selectedPreviousPoint.map { "Prev: \(formattedValue($0))" } ?? " ")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 4)

            if points.isEmpty {
                Text("No routes in this period")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .frame(maxHeight: .infinity)
            } else {
                Chart {
                    ForEach(points) { point in
                        LineMark(
                            x: .value("Date", point.bucketDate, unit: calendarUnit),
                            y: .value(metric.label, point.value(for: metric))
                        )
                        .foregroundStyle(by: .value("Series", "Current"))
                        .lineStyle(StrokeStyle(lineWidth: 2.5))
                    }

                    if showPrevious {
                        ForEach(shiftedPreviousPoints) { point in
                            LineMark(
                                x: .value("Date", point.bucketDate, unit: calendarUnit),
                                y: .value(metric.label, point.value(for: metric))
                            )
                            .foregroundStyle(by: .value("Series", "Previous"))
                            .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [5, 3]))
                        }
                    }

                    ForEach(points) { point in
                        PointMark(
                            x: .value("Date", point.bucketDate, unit: calendarUnit),
                            y: .value(metric.label, point.value(for: metric))
                        )
                        .foregroundStyle(by: .value("Series", "Current"))
                        .symbolSize(selectedBucketDate != nil && selectedPoint?.id == point.id ? 350 : 180)
                    }

                    if showPrevious {
                        ForEach(shiftedPreviousPoints) { point in
                            PointMark(
                                x: .value("Date", point.bucketDate, unit: calendarUnit),
                                y: .value(metric.label, point.value(for: metric))
                            )
                            .foregroundStyle(by: .value("Series", "Previous"))
                            .symbolSize(110)
                        }
                    }
                }
                .chartForegroundStyleScale([
                    "Current":  themeColor,
                    "Previous": themeColor.opacity(0.4)
                ])
                .chartLegend(.hidden)
                .chartXAxis {
                    AxisMarks { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel {
                                Text(period.formatXLabel(date))
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
                                Text(compactYLabel(v))
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
                                            selectedBucketDate = date
                                        }
                                    }
                                    .onEnded { _ in
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                            withAnimation { selectedBucketDate = nil }
                                        }
                                    }
                            )
                    }
                }
                .frame(maxHeight: .infinity)
            }
        }
    }

    private var calendarUnit: Calendar.Component {
        switch period {
        case .oneWeek, .oneMonth:      return .day
        case .threeMonths, .sixMonths: return .weekOfYear
        case .yearToDate, .oneYear:    return .month
        }
    }

    private func bucketLabel(for date: Date) -> String {
        let f = DateFormatter()
        switch period {
        case .oneWeek:
            f.dateFormat = "EEEE, MMM d"
            return f.string(from: date)
        case .oneMonth:
            f.dateFormat = "MMM d, yyyy"
            return f.string(from: date)
        case .threeMonths, .sixMonths:
            let end = Calendar.current.date(byAdding: .day, value: 6, to: date) ?? date
            f.dateFormat = "MMM d"
            return "\(f.string(from: date)) – \(f.string(from: end))"
        case .yearToDate, .oneYear:
            f.dateFormat = "MMMM yyyy"
            return f.string(from: date)
        }
    }

    private func formattedValue(_ point: ChartDataPoint) -> String {
        switch metric {
        case .distance: return MetricsFormatting.formatDistance(distance: point.distance, usingMetric: usingMetric)
        case .time:     return MetricsFormatting.formatTime(time: point.time)
        case .routes:   return "\(point.routes) \(point.routes == 1 ? "route" : "routes")"
        }
    }

    private func compactYLabel(_ value: Double) -> String {
        switch metric {
        case .distance:
            let converted = usingMetric ? value / 1000 : value * 0.000621371
            if converted >= 1000 { return String(format: "%.0fk", converted / 1000) }
            return String(format: "%.0f", converted)
        case .time:
            let hours = Int(value) / 3600
            let mins  = (Int(value) % 3600) / 60
            if hours > 0 { return "\(hours)h" }
            return "\(mins)m"
        case .routes:
            return "\(Int(value))"
        }
    }
}

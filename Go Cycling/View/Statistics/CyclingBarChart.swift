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

    @Binding var selectedBucketDate: Date?

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

    // Dense periods (1M and up) render every point too close together for
    // full-size symbols to read as distinct dots, so only draw them all when
    // there's room and otherwise show just the one the user has selected.
    private var showAllPointMarks: Bool { points.count <= 20 }

    private var unselectedSymbolSize: Double {
        switch points.count {
        case ..<10:   return 180
        case 10..<20: return 70
        default:      return 26
        }
    }

    private var selectedSymbolSize: Double { unselectedSymbolSize * 2 }

    // Use the theme color's complementary hue (opposite side of the color
    // wheel) so "Previous" is maximally distinct from "Current" no matter
    // which color — including a custom one — the user picks. A desaturated
    // theme color has no meaningful "opposite" hue, so fall back to a
    // neutral gray in that edge case instead of complementing noise.
    private var previousSeriesColor: Color {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        UIColor(themeColor).getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil)

        guard saturation >= 0.15 else {
            let systemGrayBrightness: CGFloat = 0.56
            return brightness > systemGrayBrightness ? Color(white: 0.25) : Color(white: 0.85)
        }

        let complementaryHue = (hue + 0.5).truncatingRemainder(dividingBy: 1.0)
        return Color(hue: complementaryHue, saturation: saturation * 0.75, brightness: brightness)
    }

    // Period totals shown alongside the per-dot callout, independent of selection.
    private var currentTotalPoint: ChartDataPoint {
        ChartDataPoint(
            bucketDate: Date(),
            distance: points.reduce(0) { $0 + $1.distance },
            time: points.reduce(0) { $0 + $1.time },
            routes: points.reduce(0) { $0 + $1.routes },
            elevationGain: points.reduce(0) { $0 + $1.elevationGain }
        )
    }

    private var previousTotalPoint: ChartDataPoint {
        ChartDataPoint(
            bucketDate: Date(),
            distance: previousPoints.reduce(0) { $0 + $1.distance },
            time: previousPoints.reduce(0) { $0 + $1.time },
            routes: previousPoints.reduce(0) { $0 + $1.routes },
            elevationGain: previousPoints.reduce(0) { $0 + $1.elevationGain }
        )
    }

    private var totalChangePct: Double {
        let current  = currentTotalPoint.value(for: metric)
        let previous = previousTotalPoint.value(for: metric)
        guard previous > 0 else { return current > 0 ? 100 : 0 }
        return ((current - previous) / previous) * 100
    }

    private func changeString(for pct: Double) -> String {
        let rounded = Int(round(pct))
        if rounded == 0 { return "0%" }
        let sym = rounded > 0 ? "↑" : "↓"
        let mag = abs(rounded) < 999 ? "\(abs(rounded))" : ">999"
        return "\(sym)\(mag)%"
    }

    // Swift Charts' automatic axis ticks round to "nice" numbers in raw
    // seconds, which almost never lines up with clean time values (e.g.
    // "33m", "1h6m"). Snap ticks to round minute/hour steps instead.
    private var timeAxisValues: [Double] {
        let currentMax  = points.map { $0.value(for: .time) }.max() ?? 0
        let previousMax = showPrevious ? (shiftedPreviousPoints.map { $0.value(for: .time) }.max() ?? 0) : 0
        let maxValue = max(currentMax, previousMax)
        guard maxValue > 0 else { return [0, 900, 1800, 2700, 3600] }

        let niceSteps: [Double] = [300, 600, 900, 1800, 3600, 7200, 10800, 21600, 43200, 86400]
        let targetTickCount = 4.0
        let rawStep = maxValue / targetTickCount
        let step = niceSteps.first(where: { $0 >= rawStep }) ?? (ceil(rawStep / 86400) * 86400)

        var values: [Double] = []
        var v = 0.0
        while v <= maxValue + step {
            values.append(v)
            v += step
        }
        return values
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Fixed-height callout (3 lines always to prevent layout jump)
            HStack(alignment: .top) {
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
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Total")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formattedValue(currentTotalPoint))
                        .font(.title3.bold())
                    Text(showPrevious ? "\(changeString(for: totalChangePct)) vs previous" : " ")
                        .font(.caption)
                        .foregroundColor(totalChangePct >= 0 ? .green : .red)
                }
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
                        AreaMark(
                            x: .value("Date", point.bucketDate),
                            y: .value(metric.label, point.value(for: metric))
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [themeColor.opacity(0.55), themeColor.opacity(0.08)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }

                    ForEach(points) { point in
                        LineMark(
                            x: .value("Date", point.bucketDate),
                            y: .value(metric.label, point.value(for: metric))
                        )
                        .foregroundStyle(by: .value("Series", "Current"))
                        .lineStyle(StrokeStyle(lineWidth: 2.5))
                    }

                    if showPrevious {
                        ForEach(shiftedPreviousPoints) { point in
                            LineMark(
                                x: .value("Date", point.bucketDate),
                                y: .value(metric.label, point.value(for: metric))
                            )
                            .foregroundStyle(by: .value("Series", "Previous"))
                            .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 3]))
                        }
                    }

                    ForEach(points) { point in
                        let isSelected = selectedBucketDate != nil && selectedPoint?.id == point.id
                        if showAllPointMarks || isSelected {
                            PointMark(
                                x: .value("Date", point.bucketDate),
                                y: .value(metric.label, point.value(for: metric))
                            )
                            .foregroundStyle(by: .value("Series", "Current"))
                            .symbolSize(isSelected ? selectedSymbolSize : unselectedSymbolSize)
                        }
                    }

                    if showPrevious && showAllPointMarks {
                        ForEach(shiftedPreviousPoints) { point in
                            PointMark(
                                x: .value("Date", point.bucketDate),
                                y: .value(metric.label, point.value(for: metric))
                            )
                            .foregroundStyle(by: .value("Series", "Previous"))
                            .symbolSize(unselectedSymbolSize * 0.6)
                        }
                    }
                }
                .chartForegroundStyleScale([
                    "Current":  themeColor,
                    "Previous": previousSeriesColor
                ])
                .chartLegend(.hidden)
                .chartXAxis {
                    if let stride = period.axisStride {
                        AxisMarks(values: .stride(by: stride)) { value in
                            if let date = value.as(Date.self) {
                                AxisValueLabel {
                                    Text(period.formatXLabel(date))
                                        .font(.caption)
                                }
                            }
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [3]))
                        }
                    } else {
                        AxisMarks { value in
                            if let date = value.as(Date.self) {
                                AxisValueLabel {
                                    Text(period.formatXLabel(date))
                                        .font(.caption)
                                }
                            }
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [3]))
                        }
                    }
                }
                .chartYAxis {
                    if metric == .time {
                        AxisMarks(position: .leading, values: timeAxisValues) { value in
                            if let v = value.as(Double.self) {
                                AxisValueLabel {
                                    Text(compactYLabel(v))
                                        .font(.caption)
                                }
                            }
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [3]))
                        }
                    } else {
                        AxisMarks(position: .leading) { value in
                            if let v = value.as(Double.self) {
                                AxisValueLabel {
                                    Text(compactYLabel(v))
                                        .font(.caption)
                                }
                            }
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [3]))
                        }
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
                            )
                    }
                }
                .frame(maxHeight: .infinity)
            }
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
        case .distance:      return MetricsFormatting.formatDistance(distance: point.distance, usingMetric: usingMetric)
        case .time:          return MetricsFormatting.formatTime(time: point.time)
        case .routes:        return "\(point.routes) \(point.routes == 1 ? "route" : "routes")"
        case .elevationGain: return MetricsFormatting.formatElevationWithoutUnits(elevation: point.elevationGain, usingMetric: usingMetric) + " " + MetricsFormatting.getElevationUnits(usingMetric: usingMetric)
        }
    }

    private func compactYLabel(_ value: Double) -> String {
        switch metric {
        case .distance:
            let unit = MetricsFormatting.getDistanceUnits(usingMetric: usingMetric)
            let converted = usingMetric ? value / 1000 : value * 0.000621371
            if converted >= 1000 { return String(format: "%.0fk %@", converted / 1000, unit) }
            return String(format: "%.0f %@", converted, unit)
        case .time:
            let totalMinutes = Int(value.rounded()) / 60
            let hours = totalMinutes / 60
            let mins  = totalMinutes % 60
            if hours > 0 { return mins > 0 ? "\(hours)h\(mins)m" : "\(hours)h" }
            return "\(mins)m"
        case .routes:
            return "\(Int(value))"
        case .elevationGain:
            let unit = MetricsFormatting.getElevationUnits(usingMetric: usingMetric)
            let converted = usingMetric ? value : value * 3.28084
            return String(format: "%.0f %@", converted, unit)
        }
    }
}

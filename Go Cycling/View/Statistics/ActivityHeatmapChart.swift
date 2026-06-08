//
//  ActivityHeatmapChart.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2026-05-23.
//

import SwiftUI
import UIKit

// MARK: - Internal data types

fileprivate struct HeatmapDay: Identifiable {
    var id: Date { date }
    let date: Date
    let value: Double
    let dayOfWeek: Int   // 0 = Mon, 6 = Sun
    let weekIndex: Int
}

fileprivate struct HeatmapWeekRow: Identifiable {
    var id: Int { weekIndex }
    let weekIndex: Int
    let slots: [HeatmapDay?]   // always 7 elements
    let monthLabel: String?    // non-nil = first week of a new calendar month
    let isMonthStart: Bool
}

// MARK: - Chart view

@available(iOS 16, *)
struct ActivityHeatmapChart: View {
    let valueData: [Date: Double]
    let metric: ChartMetric
    let period: ChartPeriod
    let themeColor: Color
    let usingMetric: Bool

    @State private var selectedDay: HeatmapDay? = nil

    private static let dayLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    private let cellSpacing: CGFloat = 3
    private let monthLabelWidth: CGFloat = 32
    private let legendCellSize: CGFloat = 13

    private var maxValue: Double { valueData.values.max() ?? 1 }
    private var weekRows: [HeatmapWeekRow] { buildWeekRows() }

    // Cell size from screen width; caller applies .padding(.horizontal) = 32pt total
    private var cellSize: CGFloat {
        let contentWidth = UIScreen.main.bounds.width - 32
        return max(28, (contentWidth - monthLabelWidth - 4 - CGFloat(6) * cellSpacing) / 7)
    }

    // MARK: - Body
    //
    // The view IS a ScrollView — it fills whatever space it is given.
    // The section header (callout + day labels) is pinned so it stays visible while scrolling.
    // Callers should use .safeAreaInset to add fixed pickers above/below without nesting this
    // inside another layout container that fights for height.

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                Section {
                    ForEach(weekRows) { row in weekRowView(row) }

                    // Legend at very bottom of scrollable content
                    legendView
                        .padding(.horizontal, 4)
                        .padding(.top, 8)
                        .padding(.bottom, 12)

                } header: {
                    // Pinned: callout row + day-of-week labels
                    VStack(spacing: 0) {
                        calloutRow
                            .frame(height: 20)
                            .padding(.horizontal, 4)
                            .padding(.top, 8)
                            .padding(.bottom, 4)
                        dayHeaderRow
                            .padding(.bottom, 4)
                    }
                    .background(Color(.systemBackground))
                }
            }
        }
    }

    // MARK: - Subviews

    private var calloutRow: some View {
        Group {
            if let day = selectedDay {
                HStack(spacing: 6) {
                    Text(formattedDate(day.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if day.value > 0 {
                        Text("· \(formattedValue(day.value))")
                            .font(.caption.bold())
                    } else {
                        Text("· No routes")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .transition(.opacity.animation(.easeInOut(duration: 0.15)))
            } else {
                Text(" ").font(.caption)
            }
        }
    }

    private var dayHeaderRow: some View {
        HStack(spacing: 4) {
            Color.clear.frame(width: monthLabelWidth)
            HStack(spacing: cellSpacing) {
                ForEach(0..<7, id: \.self) { col in
                    Text(ActivityHeatmapChart.dayLabels[col])
                        .font(.system(size: min(cellSize * 0.28, 11), weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(width: cellSize)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }

    private func weekRowView(_ row: HeatmapWeekRow) -> some View {
        let cs = cellSize
        let cornerRadius = max(4, cs * 0.15)
        return VStack(spacing: 0) {
            // Thin divider + breathing room at each month boundary (skip the very first row)
            if row.isMonthStart && row.weekIndex > 0 {
                HStack(spacing: 4) {
                    Color.clear.frame(width: monthLabelWidth)
                    Color(UIColor.separator).frame(height: 0.5)
                }
                .padding(.vertical, 5)
            }

            HStack(spacing: 4) {
                // Month label in left gutter (first week of each new month only)
                if let label = row.monthLabel {
                    Text(label)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.secondary)
                        .frame(width: monthLabelWidth, alignment: .leading)
                } else {
                    Color.clear.frame(width: monthLabelWidth)
                }

                // 7 day cells
                HStack(spacing: cellSpacing) {
                    ForEach(0..<7, id: \.self) { col in
                        if let day = row.slots[col] {
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .fill(cellColor(for: day.value))
                                .frame(width: cs, height: cs)
                                .onTapGesture {
                                    withAnimation {
                                        selectedDay = (selectedDay?.id == day.id) ? nil : day
                                    }
                                }
                        } else {
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .fill(Color(UIColor.systemGray6).opacity(0.3))
                                .frame(width: cs, height: cs)
                        }
                    }
                }
            }
            .padding(.vertical, cellSpacing / 2)
        }
    }

    private var legendView: some View {
        HStack(spacing: 4) {
            Text("Less")
                .font(.caption2)
                .foregroundColor(.secondary)
            ForEach([0.0, 0.25, 0.5, 0.75, 1.0] as [Double], id: \.self) { f in
                RoundedRectangle(cornerRadius: 2)
                    .fill(legendColor(fraction: f))
                    .frame(width: legendCellSize, height: legendCellSize)
            }
            Text("More")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Colors

    private func cellColor(for value: Double) -> Color {
        if value <= 0 { return Color(UIColor.systemGray5) }
        let linear = min(value / max(maxValue, 1), 1.0)
        let intensity = sqrt(linear)   // sqrt lifts low values so all metrics look similarly vibrant
        return themeColor.opacity(0.2 + intensity * 0.8)
    }

    private func legendColor(fraction: Double) -> Color {
        if fraction == 0 { return Color(UIColor.systemGray5) }
        let intensity = sqrt(fraction)
        return themeColor.opacity(0.2 + intensity * 0.8)
    }

    // MARK: - Formatting

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d, yyyy"
        return f.string(from: date)
    }

    private func formattedValue(_ value: Double) -> String {
        switch metric {
        case .routes:
            let n = Int(round(value))
            return "\(n) \(n == 1 ? "route" : "routes")"
        case .distance:
            return MetricsFormatting.formatDistance(distance: value, usingMetric: usingMetric)
        case .time:
            return MetricsFormatting.formatTime(time: value)
        }
    }

    // MARK: - Data building

    private func buildWeekRows() -> [HeatmapWeekRow] {
        var cal = Calendar.current
        cal.timeZone = .current
        cal.firstWeekday = 2   // weeks start on Monday

        let today = cal.startOfDay(for: Date())

        let startDate: Date
        switch period {
        case .threeMonths: startDate = cal.date(byAdding: .day, value: -89,  to: today) ?? today
        case .sixMonths:   startDate = cal.date(byAdding: .day, value: -179, to: today) ?? today
        case .yearToDate:
            let year = cal.component(.year, from: today)
            var c = DateComponents(); c.year = year; c.month = 1; c.day = 1
            startDate = cal.date(from: c) ?? today
        case .oneYear:     startDate = cal.date(byAdding: .day, value: -364, to: today) ?? today
        default:           startDate = cal.date(byAdding: .day, value: -89,  to: today) ?? today
        }

        var days: [HeatmapDay] = []
        var current = startDate
        var weekIndex = 0
        var lastWeekOfYear = -1

        while current <= today {
            let weekOfYear = cal.component(.weekOfYear, from: current)
            if lastWeekOfYear != -1 && weekOfYear != lastWeekOfYear { weekIndex += 1 }
            lastWeekOfYear = weekOfYear

            let weekday   = cal.component(.weekday, from: current)
            let dayOfWeek = (weekday + 5) % 7   // 1=Sun→6, 2=Mon→0, …

            days.append(HeatmapDay(date: current, value: valueData[current] ?? 0,
                                   dayOfWeek: dayOfWeek, weekIndex: weekIndex))

            guard let next = cal.date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }

        let byWeek = Dictionary(grouping: days, by: \.weekIndex)
        let sortedIndices = byWeek.keys.sorted()

        let monthFmt = DateFormatter()
        monthFmt.dateFormat = "MMM"

        var rows: [HeatmapWeekRow] = []
        var prevMonth = -1

        for idx in sortedIndices {
            let weekDays = byWeek[idx] ?? []

            var slots: [HeatmapDay?] = Array(repeating: nil, count: 7)
            for d in weekDays { slots[d.dayOfWeek] = d }

            let firstDay  = (0..<7).compactMap { slots[$0] }.first
            let monthNum  = firstDay.flatMap { cal.dateComponents([.month], from: $0.date).month } ?? -1
            let isNewMonth = monthNum != prevMonth && monthNum != -1
            let monthLabel: String? = isNewMonth ? firstDay.map { monthFmt.string(from: $0.date) } : nil

            rows.append(HeatmapWeekRow(weekIndex: idx, slots: slots,
                                       monthLabel: monthLabel, isMonthStart: isNewMonth))

            if monthNum != -1 { prevMonth = monthNum }
        }

        return rows
    }
}

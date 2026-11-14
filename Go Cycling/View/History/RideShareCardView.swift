//
//  RideShareCardView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2026-11-13.
//

import SwiftUI
import MapKit

// A square share card for a ride, laid out at RideShareImageRenderer.canvasSize and rendered to an image
struct RideShareCardView: View {
    let style: RideShareStyle
    let content: RideShareContent
    // Map with the route drawn on it; only used by the map style, which falls back to a plain background without it
    let mapImage: UIImage?
    let appearance: RideShareAppearance

    private var accent: Color { Color(content.accentColor) }
    private var isDark: Bool { appearance.isDark }
    private var foreground: Color { isDark ? .white : Color(white: 0.08) }
    // Fades behind text on the map card: black over a dark map, white over a light one
    private var scrim: Color { isDark ? .black : .white }

    var body: some View {
        Group {
            switch style {
            case .map:
                mapCard
            case .route:
                routeCard
            case .stats:
                statsCard
            }
        }
        .frame(width: RideShareImageRenderer.canvasSize.width, height: RideShareImageRenderer.canvasSize.height)
        .clipped()
        .foregroundColor(foreground)
    }

    // MARK: Styles

    var mapCard: some View {
        ZStack {
            if let mapImage = mapImage {
                Image(uiImage: mapImage)
                    .resizable()
            } else {
                plainBackground
                routeLine
                    .padding(EdgeInsets(top: 80, leading: 40, bottom: 130, trailing: 40))
            }

            VStack(spacing: 0) {
                header
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 16)
                    .background(LinearGradient(colors: [scrim.opacity(isDark ? 0.75 : 0.85), scrim.opacity(isDark ? 0.4 : 0.5), .clear], startPoint: .top, endPoint: .bottom))
                Spacer()
                VStack(spacing: 14) {
                    statsRow(stats: content.allStats)
                    // Trailing so Apple's Maps attribution in the bottom-left corner stays visible
                    branding(trailing: true)
                }
                .padding(16)
                .padding(.top, 36)
                // In light mode the fade eases off at the very bottom so Apple's Maps attribution isn't washed out
                .background(LinearGradient(colors: isDark ? [.clear, scrim.opacity(0.6), scrim.opacity(0.85)] : [.clear, scrim.opacity(0.7), scrim.opacity(0.75), scrim.opacity(0.3)],
                                           startPoint: .top, endPoint: .bottom))
            }
        }
    }

    var routeCard: some View {
        ZStack {
            plainBackground
            VStack(spacing: 0) {
                header
                    .frame(maxWidth: .infinity, alignment: .leading)
                routeLine
                    .padding(.vertical, 18)
                    .padding(.horizontal, 24)
                VStack(spacing: 14) {
                    statsRow(stats: content.allStats)
                    branding
                }
            }
            .padding(16)
        }
    }

    var statsCard: some View {
        ZStack {
            // Light mode uses a soft tint of the accent so dark text stays readable on any colour
            LinearGradient(colors: isDark ? [accent, accent.opacity(0.55), .black] : [accent.opacity(0.45), accent.opacity(0.15), .white],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            VStack(alignment: .leading, spacing: 0) {
                header
                Spacer()
                Text(content.distance.value)
                    .font(.system(size: 60, weight: .heavy, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text(content.distance.label.uppercased())
                    .font(.system(size: 12, weight: .semibold))
                    .opacity(0.8)
                    .padding(.bottom, 20)
                statsRow(stats: content.otherStats, valueSize: 22)
                Spacer()
                branding
            }
            .padding(20)
        }
    }

    // MARK: Building blocks

    var plainBackground: some View {
        LinearGradient(colors: isDark ? [Color(white: 0.12), Color(white: 0.04)] : [Color(white: 0.98), Color(white: 0.89)],
                       startPoint: .top, endPoint: .bottom)
    }

    // The route in the accent colour: glowing on dark backgrounds, with a dark outline on light ones so pale colours stay visible
    var routeLine: some View {
        let strokeStyle = StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
        return ZStack {
            if !isDark {
                RouteShape(coordinates: content.coordinates)
                    .stroke(Color.black.opacity(0.55), style: StrokeStyle(lineWidth: 7, lineCap: .round, lineJoin: .round))
            }
            RouteShape(coordinates: content.coordinates)
                .stroke(accent, style: strokeStyle)
                .shadow(color: isDark ? accent.opacity(0.8) : .clear, radius: 6)
        }
    }

    var header: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(content.title)
                .font(.system(size: 20, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(content.dateText)
                .font(.system(size: 12, weight: .medium))
                .opacity(0.85)
        }
    }

    // Each stat takes its natural width with equal gaps between them, so long values like
    // "27.7 km/h" aren't squeezed into an equal-width column while short ones leave empty space
    func statsRow(stats: [RideShareContent.Stat], valueSize: CGFloat = 18) -> some View {
        HStack(alignment: .bottom, spacing: 0) {
            ForEach(Array(stats.enumerated()), id: \.element.id) { index, stat in
                if index > 0 {
                    Spacer(minLength: 10)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(stat.value)
                        .font(.system(size: valueSize, weight: .bold, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    Text(stat.label.uppercased())
                        .font(.system(size: 9, weight: .semibold))
                        .opacity(0.75)
                        .lineLimit(1)
                }
            }
        }
    }

    var branding: some View {
        branding(trailing: false)
    }

    // The user's chosen app icon and the app name
    func branding(trailing: Bool) -> some View {
        HStack(spacing: 8) {
            if trailing {
                Spacer()
            }
            if let icon = content.appIcon {
                Image(uiImage: icon)
                    .resizable()
                    .frame(width: 22, height: 22)
                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
            }
            Text("Go Cycling")
                .font(.system(size: 13, weight: .semibold))
            if !trailing {
                Spacer()
            }
        }
    }
}

// Draws a route's shape scaled to fit, preserving its proportions (projected the same way as the map)
struct RouteShape: Shape {
    let points: [MKMapPoint]

    init(coordinates: [CLLocationCoordinate2D]) {
        points = coordinates.map { MKMapPoint($0) }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard points.count > 1,
              let minX = points.map(\.x).min(), let maxX = points.map(\.x).max(),
              let minY = points.map(\.y).min(), let maxY = points.map(\.y).max() else {
            return path
        }

        let routeWidth = max(maxX - minX, 1)
        let routeHeight = max(maxY - minY, 1)
        let scale = min(rect.width / routeWidth, rect.height / routeHeight)
        // Centre the route in the available space
        let offsetX = rect.minX + (rect.width - routeWidth * scale) / 2
        let offsetY = rect.minY + (rect.height - routeHeight * scale) / 2

        for (index, point) in points.enumerated() {
            let cgPoint = CGPoint(x: offsetX + (point.x - minX) * scale, y: offsetY + (point.y - minY) * scale)
            if index == 0 { path.move(to: cgPoint) } else { path.addLine(to: cgPoint) }
        }
        return path
    }
}

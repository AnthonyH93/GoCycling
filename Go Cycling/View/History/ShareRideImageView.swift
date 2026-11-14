//
//  ShareRideImageView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2026-11-13.
//

import SwiftUI

// Lets the user pick a share card style for a ride, previews it, and shares it as an image
struct ShareRideImageView: View {
    let bikeRide: BikeRide

    @EnvironmentObject var preferences: Preferences
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var style: RideShareStyle = .map
    // Resolved when the sheet appears: the remembered choice, or the system appearance
    @State private var appearance: RideShareAppearance = .dark
    // Metres around the start and end of the route that are hidden; resolved when the sheet appears from the last choice
    @State private var privacyDistance: Double = RoutePrivacy.defaultDistance
    @State private var content: RideShareContent? = nil
    // Rendered cards keyed by appearance, style and privacy distance, so switching back and forth doesn't re-render
    @State private var renderedImages: [String: UIImage] = [:]
    @State private var mapSnapshotsInProgress: Set<String> = []
    @State private var sharedImage: SharedImage? = nil

    private var currentImage: UIImage? { renderedImages[imageKey(style, appearance)] }
    // Map and Route show the route, so they're unavailable when the privacy distance hides all of it
    private var styleUnavailable: Bool { style != .stats && content?.routeHidden == true }
    private var privacyOption: RoutePrivacy.Option {
        RoutePrivacy.nearestOption(to: privacyDistance, usingMetric: preferences.usingMetric)
    }

    private var privacyBinding: Binding<RoutePrivacy.Option> {
        Binding(
            get: { privacyOption },
            set: { option in
                privacyDistance = option.metres
                RoutePrivacy.savePreference(option.metres)
                content = RideShareContent(bikeRide: bikeRide, preferences: preferences, privacyDistance: option.metres)
                renderImages()
                telemetryManager.sendCyclingSignal(tab: telemetryTab, action: TelemetryCyclingAction.SharePrivacy)
            }
        )
    }

    let telemetryManager = TelemetryManager.sharedTelemetryManager
    let telemetryTab = TelemetryTab.History

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Picker("Style", selection: $style) {
                    ForEach(RideShareStyle.allCases) { style in
                        Text(style.rawValue).tag(style)
                    }
                }
                .pickerStyle(.segmented)

                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(.secondarySystemFill))
                    if styleUnavailable {
                        Text("This ride doesn't go far enough to show any of its route while hiding \(privacyOption.label) around the start and end. Hide less below, or choose Stats.")
                            .font(.callout)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(32)
                    } else if let image = currentImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    } else {
                        ProgressView()
                    }
                }
                .aspectRatio(1, contentMode: .fit)
                .frame(maxWidth: 500)
                .shadow(color: .black.opacity(0.2), radius: 10, y: 4)

                // How much of the route to hide depends on who the image is for, so it's chosen here
                if style != .stats {
                    Menu {
                        Picker("Hide Start & End", selection: privacyBinding) {
                            ForEach(RoutePrivacy.options(usingMetric: preferences.usingMetric)) { option in
                                Text(option.metres > 0 ? "Hide \(option.label) around start & end" : "Show full route").tag(option)
                            }
                        }
                    } label: {
                        Label(privacyDistance > 0 ? "Hiding \(privacyOption.label) around start & end" : "Showing full route",
                              systemImage: privacyDistance > 0 ? "eye.slash" : "eye")
                            .font(.subheadline)
                    }
                }

                Button {
                    shareCurrentImage()
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(UserPreferences.convertColourChoiceToUIColor(colour: preferences.colourChoiceConverted)))
                .disabled(currentImage == nil || styleUnavailable)
                .frame(maxWidth: 500)

                if style == .stats {
                    Text("Shares your stats without showing where you rode.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Share Ride")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        appearance = appearance.toggled
                        appearance.savePreference()
                        renderImages()
                    } label: {
                        Image(systemName: appearance.isDark ? "moon.fill" : "sun.max.fill")
                    }
                    .accessibilityLabel(appearance.isDark ? "Switch to light image" : "Switch to dark image")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(item: $sharedImage) { shared in
                ActivityViewController(activityItems: [shared.image])
            }
        }
        .navigationViewStyle(.stack)
        .onAppear {
            guard content == nil else { return }
            // Snap to an option in the user's units, so the label always matches what's hidden
            // (e.g. the 200 m default becomes 0.1 mi with imperial units)
            privacyDistance = RoutePrivacy.nearestOption(to: RoutePrivacy.preferredDistance, usingMetric: preferences.usingMetric).metres
            let rideContent = RideShareContent(bikeRide: bikeRide, preferences: preferences, privacyDistance: privacyDistance)
            content = rideContent
            if rideContent.routeHidden {
                style = .stats
            }
            appearance = RideShareAppearance.preferred(systemIsDark: colorScheme == .dark)
            renderImages()
        }
    }

    private func imageKey(_ style: RideShareStyle, _ appearance: RideShareAppearance) -> String {
        // The stats card doesn't show the route, so it doesn't depend on the privacy distance
        style == .stats ? "\(appearance.rawValue)-\(style.rawValue)" : "\(appearance.rawValue)-\(style.rawValue)-\(Int(privacyDistance))"
    }

    // Renders any cards missing for the current appearance and privacy distance
    private func renderImages() {
        guard let content = content else { return }
        let appearance = self.appearance

        // The route and stats cards don't need any network, so render them straight away.
        // Nothing that shows the route is rendered when the privacy setting hides it
        let styles: [RideShareStyle] = content.routeHidden ? [.stats] : [.route, .stats]
        for style in styles where renderedImages[imageKey(style, appearance)] == nil {
            renderedImages[imageKey(style, appearance)] = RideShareImageRenderer.render(
                RideShareCardView(style: style, content: content, mapImage: nil, appearance: appearance), appearance: appearance)
        }

        // The map card waits for the map snapshot, falling back to a plain background if it fails
        let mapKey = imageKey(.map, appearance)
        guard !content.routeHidden, renderedImages[mapKey] == nil, !mapSnapshotsInProgress.contains(mapKey) else { return }
        mapSnapshotsInProgress.insert(mapKey)
        RideShareImageRenderer.makeMapImage(for: content, appearance: appearance) { mapImage in
            renderedImages[mapKey] = RideShareImageRenderer.render(
                RideShareCardView(style: .map, content: content, mapImage: mapImage, appearance: appearance), appearance: appearance)
            mapSnapshotsInProgress.remove(mapKey)
        }
    }

    private func shareCurrentImage() {
        guard let image = currentImage else { return }
        sharedImage = SharedImage(image: image)
        telemetryManager.sendCyclingSignal(tab: telemetryTab, action: TelemetryCyclingAction.ShareImage)
    }
}

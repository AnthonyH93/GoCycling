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
    @State private var content: RideShareContent? = nil
    // Rendered cards keyed by appearance and style, so switching back and forth doesn't re-render
    @State private var renderedImages: [String: UIImage] = [:]
    @State private var mapSnapshotsInProgress: Set<String> = []
    @State private var sharedImage: SharedImage? = nil

    private var currentImage: UIImage? { renderedImages[imageKey(style, appearance)] }

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
                    if let image = currentImage {
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
                .disabled(currentImage == nil)
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
            content = RideShareContent(bikeRide: bikeRide, preferences: preferences)
            appearance = RideShareAppearance.preferred(systemIsDark: colorScheme == .dark)
            renderImages()
        }
    }

    private func imageKey(_ style: RideShareStyle, _ appearance: RideShareAppearance) -> String {
        "\(appearance.rawValue)-\(style.rawValue)"
    }

    // Renders any cards missing for the current appearance
    private func renderImages() {
        guard let content = content else { return }
        let appearance = self.appearance

        // The route and stats cards don't need any network, so render them straight away
        for style in [RideShareStyle.route, .stats] where renderedImages[imageKey(style, appearance)] == nil {
            renderedImages[imageKey(style, appearance)] = RideShareImageRenderer.render(
                RideShareCardView(style: style, content: content, mapImage: nil, appearance: appearance), appearance: appearance)
        }

        // The map card waits for the map snapshot, falling back to a plain background if it fails
        let mapKey = imageKey(.map, appearance)
        guard renderedImages[mapKey] == nil, !mapSnapshotsInProgress.contains(mapKey) else { return }
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

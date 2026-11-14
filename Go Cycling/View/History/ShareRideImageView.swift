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

    @State private var style: RideShareStyle = .map
    @State private var renderedImages: [RideShareStyle: UIImage] = [:]
    @State private var sharedImage: SharedImage? = nil
    @State private var hasStartedRendering = false

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
                    if let image = renderedImages[style] {
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

                if style == .stats {
                    Text("Shares your stats without showing where you rode.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                Spacer()

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
                .disabled(renderedImages[style] == nil)
            }
            .padding()
            .navigationTitle("Share Ride")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(item: $sharedImage) { shared in
                ActivityViewController(activityItems: [shared.image])
            }
        }
        .navigationViewStyle(.stack)
        .onAppear(perform: renderImages)
    }

    private func renderImages() {
        guard !hasStartedRendering else { return }
        hasStartedRendering = true

        let content = RideShareContent(bikeRide: bikeRide, preferences: preferences)

        // The route and stats cards don't need any network, so render them straight away
        for style in [RideShareStyle.route, .stats] {
            renderedImages[style] = RideShareImageRenderer.render(RideShareCardView(style: style, content: content, mapImage: nil))
        }

        // The map card waits for the map snapshot, falling back to a plain background if it fails
        RideShareImageRenderer.makeMapImage(for: content) { mapImage in
            renderedImages[.map] = RideShareImageRenderer.render(RideShareCardView(style: .map, content: content, mapImage: mapImage))
        }
    }

    private func shareCurrentImage() {
        guard let image = renderedImages[style] else { return }
        sharedImage = SharedImage(image: image)
        telemetryManager.sendCyclingSignal(tab: telemetryTab, action: TelemetryCyclingAction.ShareImage)
    }
}

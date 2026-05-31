//
//  SingleBikeRide.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-23.
//

import SwiftUI
import CoreLocation
import MapKit

struct SingleBikeRideView: View {
    let bikeRide: BikeRide
    let navigationTitle: String

    @EnvironmentObject var preferences: Preferences

    @State private var showingEditPopover = false
    @State private var statsExpanded = true

    let telemetryManager = TelemetryManager.sharedTelemetryManager
    let telemetryTab = TelemetryTab.History

    var body: some View {
        ZStack(alignment: .bottom) {
            RouteDetailMapView(
                coordinates: self.setupCoordinates(latitudes: bikeRide.cyclingLatitudes, longitudes: bikeRide.cyclingLongitudes),
                center: self.calculateCenter(latitudes: bikeRide.cyclingLatitudes, longitudes: bikeRide.cyclingLongitudes),
                span: self.calculateSpan(latitudes: bikeRide.cyclingLatitudes, longitudes: bikeRide.cyclingLongitudes),
                routeColor: UserPreferences.convertColourChoiceToUIColor(colour: preferences.colourChoiceConverted),
                bottomInset: 175
            )
            .ignoresSafeArea(edges: .bottom)

            statsCard
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarTitle(navigationTitle, displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if (preferences.namedRoutes) {
                    Button {
                        self.showingEditPopover = true
                        telemetryManager.sendCyclingSignal(tab: telemetryTab, action: TelemetryCyclingAction.EditRoute)
                    } label: {
                        Image(systemName: "pencil")
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditPopover) {
            RouteNameModalView(showEditModal: $showingEditPopover, bikeRideToEdit: bikeRide)
        }
        .background(TabBarHider())
        .onAppear {
            telemetryManager.sendCyclingSignal(tab: telemetryTab, action: TelemetryCyclingAction.Click)
        }
    }

    @ViewBuilder
    var cardBackground: some View {
        if #available(iOS 15.0, *) {
            RoundedRectangle(cornerRadius: 20).fill(.ultraThinMaterial)
        } else {
            RoundedRectangle(cornerRadius: 20).fill(Color(UIColor.systemBackground).opacity(0.92))
        }
    }

    @ViewBuilder
    var statsCard: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.secondary.opacity(0.4))
                .frame(width: 36, height: 4)
                .padding(.top, 8)
                .padding(.bottom, 6)

            if statsExpanded {
                VStack(spacing: 0) {
                    if preferences.namedRoutes && bikeRide.cyclingRouteName != "Uncategorized" {
                        Text(bikeRide.cyclingRouteName)
                            .font(.headline)
                            .padding(.bottom, 8)
                    }
                    VStack(spacing: 10) {
                        HStack {
                            Spacer()
                            HistoryMetricView(systemImageString: "location", metricName: "Distance", metricText: MetricsFormatting.formatDistance(distance: bikeRide.cyclingDistance, usingMetric: preferences.usingMetric))
                            Spacer()
                            HistoryMetricView(systemImageString: "timer", metricName: "Time", metricText: MetricsFormatting.formatTime(time: bikeRide.cyclingTime))
                            Spacer()
                            HistoryMetricView(systemImageString: "arrow.up.arrow.down", metricName: "Elev. Gain", metricText: MetricsFormatting.formatElevation(elevations: bikeRide.cyclingElevations, usingMetric: preferences.usingMetric))
                            Spacer()
                        }
                        HStack {
                            Spacer()
                            HistoryMetricView(systemImageString: "speedometer", metricName: "Average Speed", metricText: MetricsFormatting.formatAverageSpeed(speeds: bikeRide.cyclingSpeeds, distance: bikeRide.cyclingDistance, time: bikeRide.cyclingTime, usingMetric: preferences.usingMetric))
                            Spacer()
                            HistoryMetricView(systemImageString: "speedometer", metricName: "Top Speed", metricText: MetricsFormatting.formatTopSpeed(speeds: bikeRide.cyclingSpeeds, usingMetric: preferences.usingMetric))
                            Spacer()
                        }
                    }
                    .padding(.bottom, 12)
                }
                .transition(.opacity)
            } else {
                HStack(spacing: 20) {
                    Label(MetricsFormatting.formatDistance(distance: bikeRide.cyclingDistance, usingMetric: preferences.usingMetric), systemImage: "location")
                    Label(MetricsFormatting.formatTime(time: bikeRide.cyclingTime), systemImage: "timer")
                }
                .font(.subheadline)
                .padding(.bottom, 12)
                .transition(.opacity)
            }

            // Buffer so content clears the home indicator
            Spacer().frame(height: 28)
        }
        .frame(maxWidth: .infinity)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 12)
        .onTapGesture {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                statsExpanded.toggle()
            }
        }
    }

    func setupCoordinates(latitudes: [CLLocationDegrees], longitudes: [CLLocationDegrees]) -> [CLLocationCoordinate2D] {
        var coordinates: [CLLocationCoordinate2D] = []
        var locationsCount = latitudes.count
        if (latitudes.count > longitudes.count) { locationsCount = longitudes.count }
        for index in 0..<locationsCount {
            coordinates.append(CLLocationCoordinate2DMake(latitudes[index], longitudes[index]))
        }
        return coordinates
    }

    func calculateSpan(latitudes: [CLLocationDegrees], longitudes: [CLLocationDegrees]) -> CLLocationDegrees {
        if (latitudes.count > 0 && longitudes.count > 0) {
            var maxLatitude = latitudes[0], minLatitude = latitudes[0]
            var maxLongitude = longitudes[0], minLongitude = longitudes[0]
            for latitude in latitudes {
                if latitude < minLatitude { minLatitude = latitude }
                if latitude > maxLatitude { maxLatitude = latitude }
            }
            for longitude in longitudes {
                if longitude < minLongitude { minLongitude = longitude }
                if longitude > maxLongitude { maxLongitude = longitude }
            }
            let latitudeSpan = (maxLatitude - minLatitude) * 1.1
            let longitudeSpan = (maxLongitude - minLongitude) * 1.1
            return latitudeSpan > longitudeSpan ? latitudeSpan : longitudeSpan
        }
        return 0.1
    }

    func calculateCenter(latitudes: [CLLocationDegrees], longitudes: [CLLocationDegrees]) -> CLLocationCoordinate2D {
        if (latitudes.count > 0 && longitudes.count > 0) {
            var maxLatitude = latitudes[0], minLatitude = latitudes[0]
            var maxLongitude = longitudes[0], minLongitude = longitudes[0]
            for latitude in latitudes {
                if latitude < minLatitude { minLatitude = latitude }
                if latitude > maxLatitude { maxLatitude = latitude }
            }
            for longitude in longitudes {
                if longitude < minLongitude { minLongitude = longitude }
                if longitude > maxLongitude { maxLongitude = longitude }
            }
            return CLLocationCoordinate2D(latitude: (maxLatitude + minLatitude) / 2,
                                          longitude: (maxLongitude + minLongitude) / 2)
        }
        return CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }
}

private struct TabBarHider: UIViewControllerRepresentable {
    final class Controller: UIViewController {
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            tabBarController?.tabBar.isHidden = true
        }
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            tabBarController?.tabBar.isHidden = false
        }
    }
    func makeUIViewController(context: Context) -> Controller { Controller() }
    func updateUIViewController(_ uiViewController: Controller, context: Context) {}
}

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
    
    @EnvironmentObject var preferences: PreferencesStorage
    
    @State private var showingEditPopover = false
    
    var body: some View {
        GeometryReader { (geometry) in
            VStack {
                MapSnapshotView(location: self.calculateCenter(latitudes: bikeRide.cyclingLatitudes, longitudes: bikeRide.cyclingLongitudes),
                                span: self.calculateSpan(latitudes: bikeRide.cyclingLatitudes, longitudes: bikeRide.cyclingLongitudes),
                                coordinates: self.setupCoordinates(latitudes: bikeRide.cyclingLatitudes, longitudes: bikeRide.cyclingLongitudes))
                    .padding(.bottom, 10)
                if (min(geometry.size.width, geometry.size.height) < 600) {
                    VStack(spacing: 10) {
                        HStack {
                            Spacer()
                            HistoryMetricView(systemImageString: "location", metricName: "Distance", metricText: MetricsFormatting.formatDistance(distance: bikeRide.cyclingDistance, usingMetric: preferences.storedPreferences[0].usingMetric))
                            Spacer()
                            HistoryMetricView(systemImageString: "timer", metricName: "Time", metricText: MetricsFormatting.formatTime(time: bikeRide.cyclingTime))
                            Spacer()
                            HistoryMetricView(systemImageString: "arrow.up.arrow.down", metricName: "Elev. Gain", metricText: MetricsFormatting.formatElevation(elevations: bikeRide.cyclingElevations, usingMetric: preferences.storedPreferences[0].usingMetric))
                            Spacer()
                        }
                        HStack {
                            Spacer()
                            HistoryMetricView(systemImageString: "speedometer", metricName: "Average Speed", metricText: MetricsFormatting.formatAverageSpeed(distance: bikeRide.cyclingDistance, time: bikeRide.cyclingTime, usingMetric: preferences.storedPreferences[0].usingMetric))
                            Spacer()
                            HistoryMetricView(systemImageString: "speedometer", metricName: "Top Speed", metricText: MetricsFormatting.formatTopSpeed(speeds: bikeRide.cyclingSpeeds, usingMetric: preferences.storedPreferences[0].usingMetric))
                            Spacer()
                        }
                    }
                    .padding(.bottom, 10)
                }
                else {
                    HStack {
                        Spacer()
                        HStack {
                            HistoryMetricView(systemImageString: "location", metricName: "Distance", metricText: MetricsFormatting.formatDistance(distance: bikeRide.cyclingDistance, usingMetric: preferences.storedPreferences[0].usingMetric))
                            Spacer()
                            HistoryMetricView(systemImageString: "timer", metricName: "Time", metricText: MetricsFormatting.formatTime(time: bikeRide.cyclingTime))
                            Spacer()
                            HistoryMetricView(systemImageString: "arrow.up.arrow.down", metricName: "Elev. Gain", metricText: MetricsFormatting.formatElevation(elevations: bikeRide.cyclingElevations, usingMetric: preferences.storedPreferences[0].usingMetric))
                            Spacer()
                            HistoryMetricView(systemImageString: "speedometer", metricName: "Average Speed", metricText: MetricsFormatting.formatAverageSpeed(distance: bikeRide.cyclingDistance, time: bikeRide.cyclingTime, usingMetric: preferences.storedPreferences[0].usingMetric))
                            Spacer()
                            HistoryMetricView(systemImageString: "speedometer", metricName: "Top Speed", metricText: MetricsFormatting.formatTopSpeed(speeds: bikeRide.cyclingSpeeds, usingMetric: preferences.storedPreferences[0].usingMetric))
                        }
                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                        Spacer()
                    }
                    .padding(.bottom, 10)
                }
            }
        }
        .navigationBarTitle(navigationTitle, displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if (preferences.storedPreferences[0].namedRoutes) {
                    Button ("Edit") {
                        self.showingEditPopover = true
                    }
                    .sheet(isPresented: $showingEditPopover) {
                        RouteNameModalView(bikeRideToEdit: bikeRide)
                    }
                }
            }
        }
    }
    
    func setupCoordinates(latitudes: [CLLocationDegrees], longitudes: [CLLocationDegrees]) -> [CLLocationCoordinate2D] {
        var coordinates: [CLLocationCoordinate2D] = []
        
        var locationsCount = latitudes.count
        if (latitudes.count > longitudes.count) {
            locationsCount = longitudes.count
        }
        
        for index in 0..<locationsCount {
            coordinates.append(CLLocationCoordinate2DMake(latitudes[index], longitudes[index]))
        }
        
        return coordinates
    }
    
    func calculateSpan(latitudes: [CLLocationDegrees], longitudes: [CLLocationDegrees]) -> CLLocationDegrees {
        // Find the min and max latitude and longitude to find ideal span that fits entire route
        if (latitudes.count > 0 && longitudes.count > 0) {
            var maxLatitude: CLLocationDegrees = latitudes[0]
            var minLatitude: CLLocationDegrees = latitudes[0]
            var maxLongitude: CLLocationDegrees = longitudes[0]
            var minLongitude: CLLocationDegrees = longitudes[0]
            
            for latitude in latitudes {
                if (latitude < minLatitude) {
                    minLatitude = latitude
                }
                if (latitude > maxLatitude) {
                    maxLatitude = latitude
                }
            }
            
            for longitude in longitudes {
                if (longitude < minLongitude) {
                    minLongitude = longitude
                }
                if (longitude > maxLongitude) {
                    maxLongitude = longitude
                }
            }
            
            // Add 10% extra so that there is some space around the map
            let latitudeSpan = (maxLatitude - minLatitude) * 1.1
            let longitudeSpan = (maxLongitude - minLongitude) * 1.1
            return latitudeSpan > longitudeSpan ? latitudeSpan : longitudeSpan
        }
        else {
            return 0.1
        }
    }
    
    func calculateCenter(latitudes: [CLLocationDegrees], longitudes: [CLLocationDegrees]) -> CLLocationCoordinate2D {
        // Find the min and max latitude and longitude to find ideal span that fits entire route
        if (latitudes.count > 0 && longitudes.count > 0) {
            var maxLatitude: CLLocationDegrees = latitudes[0]
            var minLatitude: CLLocationDegrees = latitudes[0]
            var maxLongitude: CLLocationDegrees = longitudes[0]
            var minLongitude: CLLocationDegrees = longitudes[0]
            
            for latitude in latitudes {
                if (latitude < minLatitude) {
                    minLatitude = latitude
                }
                if (latitude > maxLatitude) {
                    maxLatitude = latitude
                }
            }
            
            for longitude in longitudes {
                if (longitude < minLongitude) {
                    minLongitude = longitude
                }
                if (longitude > maxLongitude) {
                    maxLongitude = longitude
                }
            }
            
            let latitudeMidpoint = (maxLatitude + minLatitude)/2
            let longitudeMidpoint = (maxLongitude + minLongitude)/2
            return CLLocationCoordinate2D(latitude: latitudeMidpoint, longitude: longitudeMidpoint)
        }
        else {
            return CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }
    }
}

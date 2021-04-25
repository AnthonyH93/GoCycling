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
    let screenWidth = UIScreen.main.bounds.size.width
    
    @EnvironmentObject var preferences: PreferencesStorage
    
    var body: some View {
        VStack {
            MapSnapshotView(location: self.calculateCenter(latitudes: bikeRide.cyclingLatitudes, longitudes: bikeRide.cyclingLongitudes),
                            span: self.calculateSpan(latitudes: bikeRide.cyclingLatitudes, longitudes: bikeRide.cyclingLongitudes),
                            coordinates: self.setupCoordinates(latitudes: bikeRide.cyclingLatitudes, longitudes: bikeRide.cyclingLongitudes))
                .padding(.bottom, 10)
            VStack(spacing: 10) {
                HStack {
                    Spacer()
                    HistoryMetricView(systemImageString: "location", metricName: "Distance", metricText: MetricsFormatting.formatDistance(distance: bikeRide.cyclingDistance, usingMetric: preferences.storedPreferences[0].usingMetric))
                    Spacer()
                    HistoryMetricView(systemImageString: "timer", metricName: "Time", metricText: MetricsFormatting.formatTime(time: bikeRide.cyclingTime))
                    Spacer()
                    HistoryMetricView(systemImageString: "arrow.up.arrow.down", metricName: "Elevation", metricText: "Temp")
                    Spacer()
                }
                HStack {
                    Spacer()
                    HistoryMetricView(systemImageString: "speedometer", metricName: "Average Speed", metricText: MetricsFormatting.formatSpeed(distance: bikeRide.cyclingDistance, time: bikeRide.cyclingTime, usingMetric: preferences.storedPreferences[0].usingMetric))
                    Spacer()
                    HistoryMetricView(systemImageString: "speedometer", metricName: "Top Speed", metricText: MetricsFormatting.formatDistance(distance: bikeRide.cyclingTime, usingMetric: preferences.storedPreferences[0].usingMetric))
                    Spacer()
                }
            }
            .padding(.bottom, 10)
        }
        .navigationBarTitle(navigationTitle, displayMode: .inline)
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
            
            let latitudeSpan = (maxLatitude - minLatitude) + 0.01
            let longitudeSpan = (maxLongitude - minLongitude) + 0.01
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

//struct SingleBikeRideView_Previews: PreviewProvider {
//    static var previews: some View {
//        SingleBikeRideView()
//    }
//}

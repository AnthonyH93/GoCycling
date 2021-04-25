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
    let screenWidth = UIScreen.main.bounds.size.width
    
    @EnvironmentObject var preferences: PreferencesStorage
    let coordinates = CLLocationCoordinate2D(latitude: 37.332077, longitude: -122.02962) // Apple Park, California
    
    var body: some View {
        VStack {
            MapSnapshotView(location: self.calculateCenter(latitudes: bikeRide.cyclingLatitudes, longitudes: bikeRide.cyclingLongitudes),
                            span: self.calculateSpan(latitudes: bikeRide.cyclingLatitudes, longitudes: bikeRide.cyclingLongitudes),
                            coordinates: self.setupCoordinates(latitudes: bikeRide.cyclingLatitudes, longitudes: bikeRide.cyclingLongitudes))
            Spacer()
            ZStack {
                Rectangle()
                    .fill(Color(UserPreferences.convertColourChoiceToUIColor(colour: preferences.storedPreferences[0].colourChoiceConverted)))
                    .opacity(0.8)
                    .frame(width: screenWidth, height: 140)
                HStack {
                    Spacer()
                    Text("1")
                    Spacer()
                    Text("2")
                    Spacer()
                    Text("3")
                    Spacer()
                }
                .padding(.bottom, 10)
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

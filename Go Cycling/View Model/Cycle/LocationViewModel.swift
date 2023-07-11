//
//  LocationViewModel.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-11.
//

import Foundation
import CoreLocation
import Combine

class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {

    // A singleton for the entire app - there should be only 1 instance of this class
    static let locationManager = LocationViewModel()
    
    private let locationManager = CLLocationManager()
    @Published var locationStatus: CLAuthorizationStatus?
    @Published var lastLocation: CLLocation?
    @Published var cyclingLocations: [CLLocation?] = []
    @Published var cyclingSpeed: CLLocationSpeed?
    @Published var cyclingSpeeds: [CLLocationSpeed?] = []
    @Published var cyclingAltitude: CLLocationDistance?
    @Published var cyclingAltitudes: [CLLocationDistance?] = []
    @Published var cyclingDistances: [CLLocationDistance?] = []
    @Published var cyclingTotalDistance: CLLocationDistance = 0.0
    @Published var cyclingDataPointCount: Int16 = 0

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    var statusString: String {
        guard let status = locationStatus else {
            return "unknown"
        }
        
        switch status {
        case .notDetermined: return "notDetermined"
        case .authorizedWhenInUse: return "authorizedWhenInUse"
        case .authorizedAlways: return "authorizedAlways"
        case .restricted: return "restricted"
        case .denied: return "denied"
        default: return "unknown"
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationStatus = status
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastLocation = location
        cyclingSpeed = location.speed
        cyclingAltitude = location.altitude
        
        let locationsCount = cyclingLocations.count
        
        // Only add the point if enough have been processed
        if (cyclingDataPointCount < 3 && locationsCount > 1) {
            cyclingDataPointCount += 1
        }
        else {
            cyclingDataPointCount = 0
            cyclingLocations.append(lastLocation)
            cyclingSpeeds.append(cyclingSpeed)
            cyclingAltitudes.append(cyclingAltitude)
            
            // Add location to array
            if (locationsCount > 1) {
                let newDistanceInMeters = lastLocation?.distance(from: (cyclingLocations[locationsCount - 2] ?? lastLocation)!)
                cyclingDistances.append(newDistanceInMeters)
                cyclingTotalDistance += newDistanceInMeters ?? 0.0
            }
        }
    }
    
    func startedCycling() {
        // Setup background location checking if authorized
        if locationStatus == .authorizedAlways {
            locationManager.pausesLocationUpdatesAutomatically = false
            locationManager.allowsBackgroundLocationUpdates = true
        }
        // Clear every location except most recent point
        let locationsCount = cyclingLocations.count
        if (locationsCount > 1) {
            let locationToKeep = cyclingLocations[locationsCount - 1]
            cyclingLocations.removeAll()
            cyclingLocations.append(locationToKeep)
        }
        // Clear all distances
        cyclingDistances.removeAll()
        cyclingSpeeds.removeAll()
        cyclingAltitudes.removeAll()
        cyclingTotalDistance = 0.0
    }
    
    func clearLocationArray() {
        cyclingLocations.removeAll()
        cyclingDistances.removeAll()
        cyclingSpeeds.removeAll()
        cyclingAltitudes.removeAll()
        cyclingTotalDistance = 0.0
    }
    
    func stopTrackingBackgroundLocation() {
        // There is no reason to allow background location updates if the user is not actively cycling
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.allowsBackgroundLocationUpdates = false
    }
}

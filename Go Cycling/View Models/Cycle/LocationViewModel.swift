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

    private let locationManager = CLLocationManager()
    @Published var locationStatus: CLAuthorizationStatus?
    @Published var lastLocation: CLLocation?
    @Published var cyclingLocations: [CLLocation?] = []
    @Published var cyclingSpeed: CLLocationSpeed?
    @Published var cyclingAltitude: CLLocationDistance?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true
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
        cyclingLocations.append(lastLocation)
        cyclingSpeed = location.speed
        cyclingAltitude = location.altitude
    }
    
    func clearLocationArray() {
        cyclingLocations.removeAll()
    }
}

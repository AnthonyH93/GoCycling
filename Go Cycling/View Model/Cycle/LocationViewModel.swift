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
    
    // A boolean for whether the location alert should be displayed
    @Published var showLocationSettingsAlert = false
    @Published var locationSettingsAlertMessage = ""

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.distanceFilter = 10
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        // Get the initial location settings alert message
        setLocationAlertMessage()
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
        // Update the location settings alert message each time the user changes the authorization status
        setLocationAlertMessage()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastLocation = location
        cyclingLocations.append(lastLocation)
        cyclingSpeed = location.speed
        cyclingAltitude = location.altitude
        cyclingSpeeds.append(cyclingSpeed)
        cyclingAltitudes.append(cyclingAltitude)
        
        // Add location to array
        let locationsCount = cyclingLocations.count
        if (locationsCount > 1) {
            let newDistanceInMeters = lastLocation?.distance(from: (cyclingLocations[locationsCount - 2] ?? lastLocation)!)
            cyclingDistances.append(newDistanceInMeters)
            cyclingTotalDistance += newDistanceInMeters ?? 0.0
        }
    }
    
    // Used to determine whether to display a message to the user to update their location settings
    func determineLocationSettingsAlertSetup(status: CLAuthorizationStatus) -> String {
        let messageIfAllowedWhileInUse =
        """
        Go Cycling requires your location to be set to "Always" to function while the app is not on the screen.
        
        Please visit your app settings and verify that location access is allowed.
        
        If you plan to leave your device screen on while cycling then your current location access will work.
        """
        
        let messageIfNotAllowed =
        """
        Go Cycling requires location permissions to track your cycling routes.
        
        Please visit your app settings and verify that location access is allowed.
        
        All of your location data will be stored solely on your device and will never be shared with anyone.
        """
        
        switch status {
            case .authorizedAlways: return ""
            case .authorizedWhenInUse: return messageIfAllowedWhileInUse
            default: return messageIfNotAllowed
        }
    }
    
    // Used to keep the alert message up to date as the authorization status changes
    func setLocationAlertMessage() {
        locationSettingsAlertMessage = determineLocationSettingsAlertSetup(status: locationStatus ?? .notDetermined)
    }
    
    // Used to decide whether to show a location settings alert when the user starts a session
    func setLocationAlertStatus() {
        if (locationSettingsAlertMessage != "") {
            showLocationSettingsAlert = true
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

//
//  MapView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-09.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapView: UIViewRepresentable {
  typealias UIViewType = MKMapView
  
//  func makeUIView(context: Context) -> MKMapView {
//    let mapView = MKMapView()
//
//    let region = MKCoordinateRegion(
//      center: CLLocationCoordinate2D(latitude: 40.71, longitude: -74),
//      span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
//    mapView.setRegion(region, animated: true)
//
//    return mapView
//  }
//
//  func updateUIView(_ uiView: MKMapView, context: Context) {}
    let locationManager = CLLocationManager()

    func makeUIView(context: Context) -> MKMapView {
        MKMapView(frame: .zero)
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        view.showsUserLocation = true
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        if locationManager.authorizationStatus != .authorizedAlways {
            locationManager.requestAlwaysAuthorization()
        }
        
//        locationManager.requestAlwaysAuthorization()
//        locationManager.requestWhenInUseAuthorization()
        
        var hasPermission = false
        switch locationManager.authorizationStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                hasPermission = true
            default:
                hasPermission = false
        }
        
        if hasPermission {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            let location: CLLocationCoordinate2D = locationManager.location!.coordinate
            let span = MKCoordinateSpan(latitudeDelta: 0.009, longitudeDelta: 0.009)
            let region = MKCoordinateRegion(center: location, span: span)
            view.setRegion(region, animated: true)
        }
        else {
            let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 40.71, longitude: -74),
            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
            view.setRegion(region, animated: true)
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}

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

    @StateObject var locationManager = LocationViewModel()
    @Binding var isCycling: Bool
    @EnvironmentObject var preferences: UserPreferences
    
    var userLatitude: String {
        return "\(locationManager.lastLocation?.coordinate.latitude ?? 0)"
    }
        
    var userLongitude: String {
        return "\(locationManager.lastLocation?.coordinate.longitude ?? 0)"
    }
    
    func makeCoordinator() -> MapView.Coordinator {
        Coordinator(self, colour: preferences.colour)
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        var control: MapView
        var colour: Color

        init(_ control: MapView, colour: Color) {
            self.control = control
            self.colour = colour
        }

        //Managing the Display of Overlays
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let polylineRenderer = MKPolylineRenderer(overlay: polyline)
                polylineRenderer.strokeColor = UIColor(colour)
                polylineRenderer.lineWidth = 8
                return polylineRenderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }

    func makeUIView(context: Context) -> MKMapView {
        MKMapView(frame: .zero)
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        view.showsUserLocation = true
        
        let authStatus = locationManager.statusString
        
        if (authStatus == "authorizedAlways" || authStatus == "authorizedWhenInUse") {
            let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(CLLocationDegrees(userLatitude)!, CLLocationDegrees(userLongitude)!)
            let span = MKCoordinateSpan(latitudeDelta: 0.009, longitudeDelta: 0.009)
            let region = MKCoordinateRegion(center: location, span: span)
            view.setRegion(region, animated: true)
            
            // Need to maintain the cyclists route if they are currently cycling
            if isCycling {
                let totalLocationCount = locationManager.cyclingLocations.count
                if (!startedCycling) {
                    startedCycling = true
                    locationCountBeforeCycling = locationManager.cyclingLocations.count
                    if (totalLocationCount > 1) {
                        locationCountBeforeCycling -= 1
                    }
                }
                let locationsCount =  totalLocationCount - locationCountBeforeCycling
                switch locationsCount {
                case _ where locationsCount < 2:
                    break
                default:
                    var locationsToRoute : [CLLocationCoordinate2D] = []
                    for i in locationCountBeforeCycling..<totalLocationCount {
                        let currentLocation = locationManager.cyclingLocations[i]
                        if (currentLocation != nil) {
                            locationsToRoute.append(currentLocation!.coordinate)
                        }
                    }
                    let route = MKPolyline(coordinates: locationsToRoute, count: locationsCount)
                    view.addOverlay(route)
                }
            }
            else {
                // Means we need to store the current route and clear the map
                if (startedCycling) {
                    locationCountBeforeCycling = 0
                    startedCycling = false
                    let overlays = view.overlays
                    view.removeOverlays(overlays)
                    locationManager.clearLocationArray()
                }
            }
            view.delegate = context.coordinator
        }
    }
}

var locationCountBeforeCycling = 0
var startedCycling = false

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(isCycling: .constant(false))
    }
}

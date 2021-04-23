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
    
    let persistenceController = PersistenceController.shared

    @StateObject var locationManager = LocationViewModel.locationManager
    @Binding var isCycling: Bool
    @Binding var centerMapOnLocation: Bool
    @EnvironmentObject var preferences: UserPreferences
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    var userLatitude: String {
        return "\(locationManager.lastLocation?.coordinate.latitude ?? 0)"
    }
        
    var userLongitude: String {
        return "\(locationManager.lastLocation?.coordinate.longitude ?? 0)"
    }
    
    func makeCoordinator() -> MapView.Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        var control: MapView

        init(_ control: MapView) {
            self.control = control
        }

        //Managing the Display of Overlays
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let polylineRenderer = MKPolylineRenderer(overlay: polyline)
                polylineRenderer.strokeColor = UIColor.systemBlue
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
            if (centerMapOnLocation) {
                view.setRegion(region, animated: true)
            }
            
            // Need to maintain the cyclists route if they are currently cycling
            if isCycling {
                if (!startedCycling) {
                    startedCycling = true
                    locationManager.startedCycling()
                }
                let locationsCount = locationManager.cyclingLocations.count
                switch locationsCount {
                case _ where locationsCount < 2:
                    break
                default:
                    var locationsToRoute : [CLLocationCoordinate2D] = []
                    for location in locationManager.cyclingLocations {
                        if (location != nil) {
                            locationsToRoute.append(location!.coordinate)
                        }
                    }
                    if (locationsToRoute.count > 1 && locationsToRoute.count <= locationManager.cyclingLocations.count) {
                        let route = MKPolyline(coordinates: locationsToRoute, count: locationsCount)
                        view.addOverlay(route)
                    }
                }
            }
            else {
                // Means we need to store the current route and clear the map
                if (startedCycling) {
                    startedCycling = false
                    let overlays = view.overlays
                    view.removeOverlays(overlays)
                    persistenceController.storeBikeRide(locations: locationManager.cyclingLocations, speeds: [locationManager.cyclingSpeed], distance: locationManager.cyclingTotalDistance, elevation: locationManager.cyclingAltitude ?? 0.0)
                    locationManager.clearLocationArray()
                }
            }
            view.delegate = context.coordinator
        }
    }
}

var startedCycling = false

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(isCycling: .constant(false), centerMapOnLocation: .constant(true))
    }
}

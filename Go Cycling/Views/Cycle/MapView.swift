//
//  MapView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-09.
//

import SwiftUI
import MapKit
import CoreLocation

// Store all coordinates of the current route (as global variables for now)
var coordinates: [CLLocationCoordinate2D] = []
var route: MKPolyline?

struct MapView: UIViewRepresentable {
    typealias UIViewType = MKMapView

    @StateObject var locationManager = LocationViewModel()
    @Binding var isCycling: Bool
    
    var userLatitude: String {
        return "\(locationManager.lastLocation?.coordinate.latitude ?? 0)"
    }
        
    var userLongitude: String {
        return "\(locationManager.lastLocation?.coordinate.longitude ?? 0)"
    }
    
    // MARK: - Coordinator for using UIKit inside SwiftUI.
        func makeCoordinator() -> MapView.Coordinator {
            Coordinator(self)
        }

        final class Coordinator: NSObject, MKMapViewDelegate {
            var control: MapView

            init(_ control: MapView) {
                self.control = control
            }

            // MARK: - Managing the Display of Overlays

            func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
                if let polyline = overlay as? MKPolyline {

                    let polylineRenderer = MKPolylineRenderer(overlay: polyline)
                    polylineRenderer.strokeColor = .blue
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
                let coordCount = coordinates.count
                print("Coordcount \(coordCount)")
                var newRouteAddition: [CLLocationCoordinate2D] = []
                // Cannot add an overlay with less than 2 points
                switch coordCount {
                case 0..<2:
                    coordinates.append(location)
                default:
                    coordinates.append(location)
                    // Current point
                    newRouteAddition.append(coordinates[coordCount - 2])
                    // Previous point
                    newRouteAddition.append(coordinates[coordCount - 1])
                    
                    //Create the new line segment
                    route = MKPolyline(coordinates: newRouteAddition, count: 2)
                    view.addOverlay(route!)
                    print("added...")
                }
                
            }
            
            view.delegate = context.coordinator
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(isCycling: .constant(false))
    }
}

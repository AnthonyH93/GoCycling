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
                if (!startedCycling) {
                    startedCycling = true
                }
                let totalLocationCount = locationManager.cyclingLocations.count
                let locationsCount =  totalLocationCount - locationCountBeforeCycling
                switch locationsCount {
                case 0..<2:
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
                if (!startedCycling) {
                    locationCountBeforeCycling += 1
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

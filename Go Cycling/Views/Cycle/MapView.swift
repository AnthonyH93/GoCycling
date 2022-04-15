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

    @EnvironmentObject var cyclingStatus: CyclingStatus
    
    @StateObject var locationManager = LocationViewModel.locationManager
    
    @Binding var centerMapOnLocation: Bool
    @Binding var cyclingStartTime: Date
    @Binding var timeCycling: TimeInterval
    
    @Environment(\.managedObjectContext) private var managedObjectContext
    @EnvironmentObject var preferences: Preferences
    @EnvironmentObject var records: RecordsStorage
    
    var userLatitude: String {
        return "\(locationManager.lastLocation?.coordinate.latitude ?? 0)"
    }
        
    var userLongitude: String {
        return "\(locationManager.lastLocation?.coordinate.longitude ?? 0)"
    }
    
    func makeCoordinator() -> MapView.Coordinator {
        Coordinator(self, colour: UserPreferences.convertColourChoiceToUIColor(colour: preferences.colourChoiceConverted))
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        var control: MapView
        var colour: UIColor

        init(_ control: MapView, colour: UIColor) {
            self.control = control
            self.colour = colour
        }

        //Managing the Display of Overlays
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let polylineRenderer = MKPolylineRenderer(overlay: polyline)
                polylineRenderer.strokeColor = colour
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
            if cyclingStatus.isCycling {
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
                        
                        // Update stroke colour if user changes colour preference after renderer was created
                        if let renderer = view.renderer(for: route) as? MKPolylineRenderer {
                            if (renderer.strokeColor != UserPreferences.convertColourChoiceToUIColor(colour: preferences.colourChoiceConverted)) {
                                renderer.strokeColor =  UserPreferences.convertColourChoiceToUIColor(colour: preferences.colourChoiceConverted)
                            }
                        }
                    }
                }
            }
            else {
                // Means we need to store the current route and clear the map
                if (startedCycling) {
                    startedCycling = false
                    let overlays = view.overlays
                    view.removeOverlays(overlays)
                    persistenceController.storeBikeRide(locations: locationManager.cyclingLocations,
                                                        speeds: locationManager.cyclingSpeeds,
                                                        distance: locationManager.cyclingTotalDistance,
                                                        elevations: locationManager.cyclingAltitudes,
                                                        startTime: cyclingStartTime,
                                                        time: timeCycling)

                    // Determine the new values of the records object after this cycling route
                    let values = Records.getBrokenRecords(existingRecords: records.storedRecords[0], speeds: locationManager.cyclingSpeeds, distance: locationManager.cyclingTotalDistance, startTime: cyclingStartTime, time: timeCycling)
                    persistenceController.updateRecords(
                        existingRecords: records.storedRecords[0],
                        totalDistance: values.totalDistance,
                        totalTime: values.totalTime,
                        totalRoutes: values.totalRoutes,
                        longestDistance: values.longestDistance,
                        longestTime: values.longestTime,
                        fastestAvgSpeed: values.fastestAvgSpeed,
                        longestDistanceDate: values.longestDistanceDate,
                        longestTimeDate: values.longestTimeDate,
                        fastestAvgSpeedDate: values.fastestAvgSpeedDate)
                    
                    locationManager.clearLocationArray()
                    locationManager.stopTrackingBackgroundLocation()
                }
            }
            view.delegate = context.coordinator
        }
    }
}

var startedCycling = false

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(centerMapOnLocation: .constant(true), cyclingStartTime: .constant(Date()), timeCycling: .constant(10))
    }
}

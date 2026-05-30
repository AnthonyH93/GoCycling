//
//  RouteDetailMapView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2026-05-30.
//

import SwiftUI
import MapKit
import CoreLocation

private class DirectionAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let bearing: Double

    init(coordinate: CLLocationCoordinate2D, bearing: Double) {
        self.coordinate = coordinate
        self.bearing = bearing
    }
}

private func bearing(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
    let lat1 = from.latitude * .pi / 180
    let lat2 = to.latitude * .pi / 180
    let dLon = (to.longitude - from.longitude) * .pi / 180
    let y = sin(dLon) * cos(lat2)
    let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
    return atan2(y, x)
}

struct RouteDetailMapView: UIViewRepresentable {
    let coordinates: [CLLocationCoordinate2D]
    let center: CLLocationCoordinate2D
    let span: CLLocationDegrees
    let routeColor: UIColor

    func makeCoordinator() -> Coordinator {
        Coordinator(routeColor: routeColor)
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        let routeColor: UIColor

        init(routeColor: UIColor) {
            self.routeColor = routeColor
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(overlay: polyline)
                renderer.strokeColor = routeColor
                renderer.lineWidth = 8
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if let direction = annotation as? DirectionAnnotation {
                let id = "direction"
                let view = mapView.dequeueReusableAnnotationView(withIdentifier: id) ?? MKAnnotationView(annotation: annotation, reuseIdentifier: id)
                view.annotation = annotation
                view.canShowCallout = false

                let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
                let image = UIImage(systemName: "chevron.right", withConfiguration: config)?
                    .withTintColor(routeColor, renderingMode: .alwaysOriginal)
                view.image = image
                view.transform = CGAffineTransform(rotationAngle: CGFloat(direction.bearing))
                view.layer.zPosition = 10
                return view
            }

            if let point = annotation as? MKPointAnnotation {
                let id = "endpoint"
                let view = (mapView.dequeueReusableAnnotationView(withIdentifier: id) as? MKMarkerAnnotationView) ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: id)
                view.annotation = annotation
                view.canShowCallout = false
                if point.title == "Start" {
                    view.markerTintColor = .systemGreen
                    view.glyphImage = UIImage(systemName: "flag.fill")
                } else {
                    view.markerTintColor = .systemRed
                    view.glyphImage = UIImage(systemName: "flag.checkered")
                }
                view.layer.zPosition = 20
                return view
            }

            return nil
        }
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = false
        mapView.showsCompass = false
        mapView.isScrollEnabled = true
        mapView.isZoomEnabled = true
        mapView.setRegion(
            MKCoordinateRegion(
                center: center,
                span: MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span)
            ),
            animated: false
        )
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)

        guard coordinates.count > 1 else { return }

        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(polyline)

        let start = MKPointAnnotation()
        start.coordinate = coordinates.first!
        start.title = "Start"

        let end = MKPointAnnotation()
        end.coordinate = coordinates.last!
        end.title = "End"

        mapView.addAnnotations([start, end])

        let arrowFractions: [Double] = [0.25, 0.5, 0.75]
        for fraction in arrowFractions {
            let index = Int(fraction * Double(coordinates.count - 1))
            let next = min(index + 1, coordinates.count - 1)
            let b = bearing(from: coordinates[index], to: coordinates[next])
            let arrow = DirectionAnnotation(coordinate: coordinates[index], bearing: b)
            mapView.addAnnotation(arrow)
        }
    }
}

//
//  RouteDetailMapView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2026-05-30.
//

import SwiftUI
import MapKit
import CoreLocation

private func dotImage(color: UIColor, diameter: CGFloat = 16) -> UIImage {
    let total = diameter + 4
    return UIGraphicsImageRenderer(size: CGSize(width: total, height: total)).image { _ in
        UIColor.white.setFill()
        UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: total, height: total)).fill()
        color.setFill()
        UIBezierPath(ovalIn: CGRect(x: 2, y: 2, width: diameter, height: diameter)).fill()
    }
}

struct RouteDetailMapView: UIViewRepresentable {
    let coordinates: [CLLocationCoordinate2D]
    let center: CLLocationCoordinate2D
    let span: CLLocationDegrees
    let routeColor: UIColor
    var bottomInset: CGFloat = 0
    var mapType: MKMapType = .standard

    func makeCoordinator() -> Coordinator {
        Coordinator(routeColor: routeColor)
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        var routeColor: UIColor

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
            guard let point = annotation as? MKPointAnnotation else { return nil }
            let id = "dot"
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: id) ?? MKAnnotationView(annotation: annotation, reuseIdentifier: id)
            view.annotation = annotation
            view.canShowCallout = false
            view.image = dotImage(color: point.title == "Start" ? .systemGreen : .systemRed)
            view.layer.zPosition = 20
            return view
        }
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = false
        mapView.showsCompass = false
        mapView.isScrollEnabled = true
        mapView.isZoomEnabled = true
        mapView.mapType = mapType
        let topLeft = MKMapPoint(CLLocationCoordinate2D(latitude: center.latitude + span / 2, longitude: center.longitude - span / 2))
        let bottomRight = MKMapPoint(CLLocationCoordinate2D(latitude: center.latitude - span / 2, longitude: center.longitude + span / 2))
        let mapRect = MKMapRect(x: min(topLeft.x, bottomRight.x),
                                y: min(topLeft.y, bottomRight.y),
                                width: abs(topLeft.x - bottomRight.x),
                                height: abs(topLeft.y - bottomRight.y))
        mapView.setVisibleMapRect(mapRect,
                                  edgePadding: UIEdgeInsets(top: 40, left: 20, bottom: bottomInset + 20, right: 20),
                                  animated: false)
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        context.coordinator.routeColor = routeColor
        if mapView.mapType != mapType { mapView.mapType = mapType }
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
    }
}

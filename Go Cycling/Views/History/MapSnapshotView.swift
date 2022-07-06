//
//  MapSnapshotView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-24.
//  Credit to: Modified code found at https://codakuma.com/swiftui-static-maps/

import SwiftUI
import MapKit

struct MapSnapshotView: View {
    let location: CLLocationCoordinate2D
    let span: CLLocationDegrees
    let coordinates: [CLLocationCoordinate2D]?
    
    @EnvironmentObject var preferences: Preferences
    
    @State private var snapshotImage: UIImage? = nil
    
    var body: some View {
        GeometryReader { geometry in
            Group {
                if let image = snapshotImage {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(uiImage: image)
                            Spacer()
                        }
                        Spacer()
                    }
                }
                else {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .background(Color(UIColor.secondarySystemBackground))
                            Spacer()
                        }
                        Spacer()
                    }
                }
            }
            // Would be simply .onAppear, but it broke in iOS 14.5
            .uiKitOnAppear {
                generateSnapshot(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
    
    func generateSnapshot(width: CGFloat, height: CGFloat) {
        
        let region = MKCoordinateRegion(
            center: self.location,
            span: MKCoordinateSpan(
                latitudeDelta: self.span,
                longitudeDelta: self.span
            )
        )
        
        // Map options
        let mapOptions = MKMapSnapshotter.Options()
        mapOptions.region = region
        mapOptions.size = CGSize(width: width, height: height)
        mapOptions.showsBuildings = true
        
        // Create the snapshotter and run it
        let snapshotter = MKMapSnapshotter(options: mapOptions)
        snapshotter.start { (snapshotOrNil, errorOrNil) in
            if let error = errorOrNil {
                print(error)
                return
            }
            if let snapshot = snapshotOrNil {
                let finalImage = UIGraphicsImageRenderer(size: snapshot.image.size).image { _ in
                    
                    snapshot.image.draw(at: .zero)

                    guard let coordinates = self.coordinates, coordinates.count > 1 else { return }
                    
                    // Convert the [CLLocationCoordinate2D] into a [CGPoint]
                    let points = coordinates.map { coordinate in
                        snapshot.point(for: coordinate)
                    }
                    
                    let path = UIBezierPath()
                    path.move(to: points[0])
                    
                    for point in points.dropFirst() {
                        path.addLine(to: point)
                    }

                    path.lineWidth = 8
                    UserPreferences.convertColourChoiceToUIColor(colour: preferences.colourChoiceConverted).setStroke()
                    path.stroke()
                }
                self.snapshotImage = finalImage
            }
        }
    }
}

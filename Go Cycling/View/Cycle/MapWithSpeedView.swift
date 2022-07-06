//
//  MapWithSpeedView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-15.
//

import SwiftUI
import CoreLocation

struct MapWithSpeedView: View {
    
    @EnvironmentObject var cyclingStatus: CyclingStatus
    
    @Binding var cyclingStartTime: Date
    @Binding var timeCycling: TimeInterval
    var screenWidth: CGFloat
    
    @StateObject var locationManager = LocationViewModel.locationManager
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var preferences: Preferences
    
    @State var mapCentered: Bool = true
    
    var body: some View {
        ZStack {
            MapView(centerMapOnLocation: $mapCentered, cyclingStartTime: $cyclingStartTime, timeCycling: $timeCycling)
            VStack {
                if (preferences.largeMetrics) {
                    LargeMetricsView(currentSpeed: $locationManager.cyclingSpeed, currentAltitude: $locationManager.cyclingAltitude, currentDistance: $locationManager.cyclingTotalDistance, screenWidth: screenWidth)
                }
                else {
                    SmallMetricsView(currentSpeed: $locationManager.cyclingSpeed, currentAltitude: $locationManager.cyclingAltitude, currentDistance: $locationManager.cyclingTotalDistance)
                }
                Spacer()
                HStack {
                    Spacer()
                    ZStack {
                        if (mapCentered) {
                            Button (action: {self.toggleMapCentered()}) {
                                MapSystemImageButton(systemImageString: "lock", buttonColour: (UserPreferences.convertColourChoiceToUIColor(colour: preferences.colourChoiceConverted)))
                                    .padding(.bottom, 5)
                                }
                        }
                        else {
                            Button (action: {self.toggleMapCentered()}) {
                                MapSystemImageButton(systemImageString: "lock.open", buttonColour: (UserPreferences.convertColourChoiceToUIColor(colour: preferences.colourChoiceConverted)))
                                    .padding(.bottom, 5)
                                }
                        }
                    }
                    Spacer()
                }
            }
        }
        Spacer()
    }
    
    func toggleMapCentered() {
        self.mapCentered = self.mapCentered ? false : true
    }
}

struct MapWithSpeedView_Previews: PreviewProvider {
    static var previews: some View {
        MapWithSpeedView(cyclingStartTime: .constant(Date()), timeCycling: .constant(10), screenWidth: UIScreen.main.bounds.width)
    }
}

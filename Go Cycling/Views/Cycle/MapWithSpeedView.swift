//
//  MapWithSpeedView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-15.
//

import SwiftUI
import CoreLocation

struct MapWithSpeedView: View {
    
    @Binding var isCycling: Bool
    @StateObject var locationManager = LocationViewModel()
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var preferences: UserPreferences
    
    var body: some View {
        ZStack {
            MapView(isCycling: $isCycling)
            VStack {
                HStack {
                    Spacer()
                    ZStack {
                        Rectangle()
                            .fill(preferences.colour)
                            .opacity(0.4)
                            .frame(width: 180, height: 70)
                            .padding(.all, 10)
                        Text(self.formatMetricsString(currentSpeed: (locationManager.cyclingSpeed ?? 0.0), currentAltitude: (locationManager.cyclingAltitude ?? 0)))
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .multilineTextAlignment(.center)
                    }
                }
                Spacer()
            }
        }
        Spacer()
    }
    
    func formatMetricsString(currentSpeed: CLLocationSpeed, currentAltitude: CLLocationDistance) -> String {
        let speedToUse = (currentSpeed < 0) ? 0.0 : currentSpeed
        
        let speedMetresPerSecond = round(100 * speedToUse)/100
        let speedKMH = round(100 * (3.6 * speedToUse))/100
        let speedMPH = round(100 * (2.23694 * speedToUse))/100
        let speedUnits = "km/h"
        
        let altitudeMetres = round(100 * currentAltitude)/100
        let altitudeFeet = round(100 * (3.28084 * currentAltitude))/100
        let altitudeUnits = "m"
        
        let returnString = """
        Current Metrics
        Speed: \(speedKMH) \(speedUnits)
        Altitude: \(altitudeMetres) \(altitudeUnits)
        """
        return returnString
    }
}

struct MapWithSpeedView_Previews: PreviewProvider {
    static var previews: some View {
        MapWithSpeedView(isCycling: .constant(false))
    }
}

//
//  MapWithSpeedView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-15.
//

import SwiftUI
import CoreLocation


//TODO:
/*
 Had speed but was passed through state, fix that somehow
 Store route at end of ride, need all those locations :)
 If speed works then maybe add altitude?
 Add settings page to disable the speed and altitude stuff
 Clean up location manager stuff with the MapWithSpeedView
 Try to get rid of those global variables :)
 */
struct MapWithSpeedView: View {
    
    @Binding var isCycling: Bool
    @StateObject var locationManager = LocationViewModel()
    
    
    var body: some View {
        ZStack {
            MapView(isCycling: $isCycling)
            VStack {
                HStack {
                    Spacer()
                    ZStack {
                        Rectangle()
                            .fill(Color.blue)
                            .opacity(0.3)
                            .frame(width: 180, height: 70)
                            .padding(.all, 10)
                        Text(self.formatMetricsString(currentSpeed: (locationManager.cyclingSpeed ?? 0.0), currentAltitude: (locationManager.cyclingAltitude ?? 0)))
                            .foregroundColor(.white)
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

//
//  SmallMetricsView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-25.
//

import SwiftUI
import CoreLocation

struct SmallMetricsView: View {
    
    @EnvironmentObject var cyclingStatus: CyclingStatus
    
    @Binding var currentSpeed: CLLocationSpeed?
    @Binding var currentAltitude: CLLocationDistance?
    @Binding var currentDistance: CLLocationDistance
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var preferences: PreferencesStorage
    
    var body: some View {
        HStack {
            Spacer()
                if (preferences.storedPreferences[0].displayingMetrics) {
                    Text(self.formatMetricsString(currentSpeed: currentSpeed ?? 0.0, currentAltitude: currentAltitude ?? 0.0, currentDistance: currentDistance))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .multilineTextAlignment(.center)
                        .padding(.all, 5)
                        .background(
                            Rectangle()
                                .fill(Color(UserPreferences.convertColourChoiceToUIColor(colour: preferences.storedPreferences[0].colourChoiceConverted)))
                                .opacity(0.4)
                                .cornerRadius(10))
                }
        }
        .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 10))
    }
    
    func formatMetricsString(currentSpeed: CLLocationSpeed, currentAltitude: CLLocationDistance, currentDistance: CLLocationDistance) -> String {
        let speedToUse = (currentSpeed < 0) ? 0.0 : currentSpeed
        
        let speedKMH = round(100 * (3.6 * speedToUse))/100
        let speedMPH = round(100 * (2.23694 * speedToUse))/100
        let speedUnits = preferences.storedPreferences[0].usingMetric ? "km/h" : "mph"
        let speedString = preferences.storedPreferences[0].usingMetric ? speedKMH : speedMPH
        
        let altitudeMetres = round(100 * currentAltitude)/100
        let altitudeFeet = round(100 * (3.28084 * currentAltitude))/100
        let altitudeUnits = preferences.storedPreferences[0].usingMetric ? "m" : "ft"
        let altitudeString = preferences.storedPreferences[0].usingMetric ? altitudeMetres : altitudeFeet
        
        let distanceKilometres = round(100 * currentDistance/1000)/100
        let distanceMiles = round(100 * (0.621371 * currentDistance/1000))/100
        let distanceUnits = preferences.storedPreferences[0].usingMetric ? "km" : "mi"
        var distanceString = preferences.storedPreferences[0].usingMetric ? distanceKilometres : distanceMiles
        
        if (!cyclingStatus.isCycling) {
            distanceString = 0.0
        }
        
        let returnString = """
        Current Cycling Metrics
        Distance: \(distanceString) \(distanceUnits)
        Speed: \(speedString) \(speedUnits)
        Altitude: \(altitudeString) \(altitudeUnits)
        """
        return returnString
    }
}

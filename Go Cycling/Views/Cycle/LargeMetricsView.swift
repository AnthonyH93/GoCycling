//
//  LargeMetricsView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-25.
//

import SwiftUI
import CoreLocation

struct LargeMetricsView: View {
    
    @EnvironmentObject var cyclingStatus: CyclingStatus
    
    @Binding var currentSpeed: CLLocationSpeed?
    @Binding var currentAltitude: CLLocationDistance?
    @Binding var currentDistance: CLLocationDistance
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var newPreferences: Preferences
    
    var screenWidth: CGFloat
    
    var body: some View {
        HStack {
            if (newPreferences.displayingMetrics) {
                HStack(alignment: .center, spacing: 10) {
                    ZStack {
                        Rectangle()
                            .fill(Color(UserPreferences.convertColourChoiceToUIColor(colour: newPreferences.colourChoiceConverted)))
                            .opacity(0.4)
                            .frame(width: screenWidth/3 - 13.3, height: 90)
                            .cornerRadius(10)
                        HStack {
                            Spacer()
                            LargeSingleMetricView(metricName: "Distance",
                                                  metricText: MetricsFormatting.formatDistanceWithoutUnits(distance: self.setCurrentDistance(),
                                                  usingMetric: newPreferences.usingMetric),
                                                  metricUnits: MetricsFormatting.getDistanceUnits(usingMetric: newPreferences.usingMetric))
                            Spacer()
                        }
                    }
                    ZStack {
                        Rectangle()
                            .fill(Color(UserPreferences.convertColourChoiceToUIColor(colour: newPreferences.colourChoiceConverted)))
                            .opacity(0.4)
                            .frame(width: screenWidth/3 - 13.3, height: 90)
                            .cornerRadius(10)
                        HStack {
                            Spacer()
                            LargeSingleMetricView( metricName: "Speed",
                                                   metricText: MetricsFormatting.formatSpeedWithoutUnits(speed: currentSpeed ?? 0.0,
                                                   usingMetric: newPreferences.usingMetric),
                                                   metricUnits: MetricsFormatting.getSpeedUnits(usingMetric: newPreferences.usingMetric))
                            Spacer()
                        }
                    }
                    ZStack {
                        Rectangle()
                            .fill(Color(UserPreferences.convertColourChoiceToUIColor(colour: newPreferences.colourChoiceConverted)))
                            .opacity(0.4)
                            .frame(width: screenWidth/3 - 13.3, height: 90)
                            .cornerRadius(10)
                        HStack {
                            Spacer()
                            LargeSingleMetricView(metricName: "Altitude",
                                                  metricText: MetricsFormatting.formatElevationWithoutUnits(elevation: currentAltitude ?? 0.0,
                                                  usingMetric: newPreferences.usingMetric),
                                                  metricUnits: MetricsFormatting.getElevationUnits(usingMetric: newPreferences.usingMetric))
                            Spacer()
                        }
                    }
                }
            }
        }
        .padding(.all, 10)
    }
    
    func setCurrentDistance() -> CLLocationDistance {
        if (cyclingStatus.isCycling) {
            return currentDistance
        }
        return 0.0
    }
}

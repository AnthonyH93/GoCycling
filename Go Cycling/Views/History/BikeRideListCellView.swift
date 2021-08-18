//
//  BikeRidesListCellView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-08-15.
//

import SwiftUI

struct BikeRideListCellView: View {
    let bikeRide: BikeRide
    let persistenceController = PersistenceController.shared
    
    @EnvironmentObject var preferences: PreferencesStorage
    
    @Environment(\.managedObjectContext) private var managedObjectContext

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text(MetricsFormatting.formatDate(date: bikeRide.cyclingStartTime))
                    .font(.headline)
                    .foregroundColor(Color(UserPreferences.convertColourChoiceToUIColor(colour: preferences.storedPreferences[0].colourChoiceConverted)))
                Spacer()
                Text(MetricsFormatting.formatStartTime(date: bikeRide.cyclingStartTime))
                    .font(.headline)
                    .foregroundColor(Color(UserPreferences.convertColourChoiceToUIColor(colour: preferences.storedPreferences[0].colourChoiceConverted)))
            }
            HStack {
                Text("Distance Cycled")
                Spacer()
                Text(MetricsFormatting.formatDistance(distance: bikeRide.cyclingDistance, usingMetric: preferences.storedPreferences[0].usingMetric))
                    .font(.headline)
            }
            HStack {
                Text("Cycling Time")
                Spacer()
                Text(MetricsFormatting.formatTime(time: bikeRide.cyclingTime))
                    .font(.headline)
            }
            HStack {
                Text("Average Speed")
                Spacer()
                Text(MetricsFormatting.formatAverageSpeed(distance: bikeRide.cyclingDistance, time: bikeRide.cyclingTime, usingMetric: preferences.storedPreferences[0].usingMetric))
                    .font(.headline)
            }
        }

    }
}

//struct BikeRideListCellView_Previews: PreviewProvider {
//    static var previews: some View {
//        BikeRideListCellView()
//    }
//}

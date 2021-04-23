//
//  StatisticsView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-03-14.
//

import SwiftUI

struct StatisticsView: View {
    let persistenceController = PersistenceController.shared
    
    @EnvironmentObject var bikeRides: BikeRideStorage
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Distance: \(bikeRides.storedBikeRides[2].cyclingDistance)")
            Text("Number of bike rides: \(bikeRides.storedBikeRides.count)")
            Text("Seconds taken: \(bikeRides.storedBikeRides[bikeRides.storedBikeRides.count - 1].cyclingTime)")
        }
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView()
    }
}

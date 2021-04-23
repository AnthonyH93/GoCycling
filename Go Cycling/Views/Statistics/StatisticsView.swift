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
        Text("Distance: \(bikeRides.storedBikeRides[2].cyclingDistance)")
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView()
    }
}

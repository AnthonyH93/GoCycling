//
//  StatisticsView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-08-23.
//

import SwiftUI

struct StatisticsView: View {
    let persistenceController = PersistenceController.shared
    
    @EnvironmentObject var preferences: PreferencesStorage
    @EnvironmentObject var bikeRides: BikeRideStorage
    @EnvironmentObject var records: RecordsStorage
    
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    var body: some View {
        VStack {
            // Temporary testing UI
            Text("Statistics Tab")
            Text("\(records.storedRecords[0].totalCyclingTime)")
            Text("\(records.storedRecords[0].totalCyclingDistance)")
            Text("\(records.storedRecords[0].longestCyclingTime)")
            Text("\(records.storedRecords[0].longestCyclingDistance)")
            Text("\(records.storedRecords[0].totalCyclingRoutes)")
            Text("\(records.storedRecords[0].fastestAverageSpeed)")
        }
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView()
    }
}

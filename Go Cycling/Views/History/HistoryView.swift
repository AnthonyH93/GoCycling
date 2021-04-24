//
//  StatisticsView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-03-14.
//

import SwiftUI

struct HistoryView: View {
    let persistenceController = PersistenceController.shared
    
    @EnvironmentObject var bikeRides: BikeRideStorage
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    var body: some View {
        BikeRidesListView()
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}

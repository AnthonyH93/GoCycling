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
        List {
            ForEach(bikeRides.storedBikeRides) { bikeRide in
                HStack {
                    Text("Distance: \(bikeRide.cyclingDistance)")
                }
            }
            .onDelete { indexSet in
                for index in indexSet {
                    managedObjectContext.delete(bikeRides.storedBikeRides[index])
                }
                do {
                    try managedObjectContext.save()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}

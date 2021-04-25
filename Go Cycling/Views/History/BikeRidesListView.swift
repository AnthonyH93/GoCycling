//
//  BikeRidesList.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-23.
//

import SwiftUI
import CoreLocation

struct BikeRidesListView: View {
    let persistenceController = PersistenceController.shared
    
    @EnvironmentObject var preferences: PreferencesStorage
    @FetchRequest(entity: BikeRide.entity(), sortDescriptors: [], predicate: nil)
    var bikeRides: FetchedResults<BikeRide>
    
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    var body: some View {
        NavigationView {
            if (bikeRides.count > 0) {
                List {
                    ForEach(bikeRides) { bikeRide in
                        NavigationLink(destination: SingleBikeRideView(bikeRide: bikeRide, navigationTitle: MetricsFormatting.formatDate(date: bikeRide.cyclingStartTime))) {
                            VStack(spacing: 10) {
                                HStack {
                                    Text(MetricsFormatting.formatDate(date: bikeRide.cyclingStartTime))
                                        .font(.headline)
                                        
                                    Spacer()
                                }
                                HStack {
                                    Text("Distance Cycled")
                                    Spacer()
                                    Text(MetricsFormatting.formatDistance(distance: bikeRide.cyclingDistance, usingMetric: preferences.storedPreferences[0].usingMetric))
                                }
                                HStack {
                                    Text("Cycling Time")
                                    Spacer()
                                    Text(MetricsFormatting.formatTime(time: bikeRide.cyclingTime))
                                }
                                HStack {
                                    Text("Average Speed")
                                    Spacer()
                                    Text(MetricsFormatting.formatAverageSpeed(distance: bikeRide.cyclingDistance, time: bikeRide.cyclingTime, usingMetric: preferences.storedPreferences[0].usingMetric))
                                }
                            }
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            managedObjectContext.delete(bikeRides[index])
                        }
                        do {
                            try managedObjectContext.save()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .navigationBarTitle("Cycling History", displayMode: .automatic)
            }
            else {
                VStack {
                    Spacer()
                    Text("No completed bike rides to display!")
                    Spacer()
                }
                .navigationBarTitle("Cycling History", displayMode: .automatic)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct BikeRidesListView_Previews: PreviewProvider {
    static var previews: some View {
        BikeRidesListView()
    }
}

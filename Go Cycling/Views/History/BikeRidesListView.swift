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
    
    @ObservedObject var bikeRideViewModel = BikeRideListViewModel()
    
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    @State private var showingActionSheet = false
    
    var body: some View {
        NavigationView {
            if (bikeRideViewModel.bikeRides.count > 0) {
                List {
                    ForEach(bikeRideViewModel.bikeRides) { bikeRide in
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
                    .onDelete(perform: self.deleteBikeRide)
                }
                .listStyle(PlainListStyle())
                .navigationBarTitle("Cycling History", displayMode: .automatic)
                .navigationBarItems(trailing: Button(bikeRideViewModel.getActionSheetTitle(), action: {
                    self.showingActionSheet = true
                }))
                .actionSheet(isPresented: $showingActionSheet, content: {
                    ActionSheet(title: Text("Sort"), message: Text("Set your preferred sorting order"), buttons:[
                        .default(Text("Date Descending (Default)"), action: bikeRideViewModel.sortByDateDescending),
                        .default(Text("Date Ascending"), action: bikeRideViewModel.sortByDateAscending),
                        .default(Text("Distance Descending"), action: bikeRideViewModel.sortByDistanceDescending),
                        .default(Text("Distance Ascending"), action: bikeRideViewModel.sortByDistanceAscending),
                        .default(Text("Time Descending"), action: bikeRideViewModel.sortByTimeDescending),
                        .default(Text("Time Ascending"), action: bikeRideViewModel.sortByTimeAscending),
                        .cancel()
                    ])
                })
                .onChange(of: bikeRideViewModel.currentSortChoice, perform: { value in
                    persistenceController.storeUserPreferences(
                        unitsChoice: preferences.storedPreferences[0].metricsChoiceConverted,
                        displayingMetrics: preferences.storedPreferences[0].displayingMetrics,
                        colourChoice: preferences.storedPreferences[0].colourChoiceConverted,
                        largeMetrics: preferences.storedPreferences[0].largeMetrics,
                        sortChoice: bikeRideViewModel.currentSortChoice)
                })
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
    
    func deleteBikeRide(at indexSet: IndexSet) {
        for index in indexSet {
            managedObjectContext.delete(bikeRideViewModel.bikeRides[index])
        }
        do {
            try managedObjectContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct BikeRidesListView_Previews: PreviewProvider {
    static var previews: some View {
        BikeRidesListView()
    }
}

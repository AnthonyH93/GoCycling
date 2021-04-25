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
                        NavigationLink(destination: SingleBikeRideView(bikeRide: bikeRide)) {
                            VStack(spacing: 10) {
                                HStack {
                                    Text(self.formatDate(date: bikeRide.cyclingStartTime))
                                        .font(.headline)
                                        
                                    Spacer()
                                }
                                HStack {
                                    Text("Distance Cycled")
                                    Spacer()
                                    Text(self.formatDistance(distance: bikeRide.cyclingDistance))
                                }
                                HStack {
                                    Text("Cycling Time")
                                    Spacer()
                                    Text(self.formatTime(time: bikeRide.cyclingTime))
                                }
                                HStack {
                                    Text("Average Speed")
                                    Spacer()
                                    Text(self.formatSpeed(distance: bikeRide.cyclingDistance, time: bikeRide.cyclingTime))
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
                .navigationBarTitle("Cycling History", displayMode: .large)
            }
            else {
                VStack {
                    Spacer()
                    Text("No completed bike rides to display!")
                    Spacer()
                }
                .navigationBarTitle("Cycling History", displayMode: .large)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func formatDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        return(dateFormatter.string(from: date))
    }
    
    func formatDistance(distance: CLLocationDistance) -> String {
        let distanceKilometres = round(100 * distance/1000)/100
        let distanceMiles = round(100 * (0.621371 * distance/1000))/100
        let distanceUnits = preferences.storedPreferences[0].usingMetric ? "km" : "mi"
        let distanceString = "\(preferences.storedPreferences[0].usingMetric ? distanceKilometres : distanceMiles) " + distanceUnits
        return distanceString
    }
    
    func formatTime(time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    func formatSpeed(distance: CLLocationDistance, time: TimeInterval) -> String {
        let speedUnits = preferences.storedPreferences[0].usingMetric ? "km/h" : "mph"
        if (time == 0) {
            return "0 " + speedUnits
        }
        let speedMetresPerSecond = distance/time
        let speedKMH = round(100 * (3.6 * speedMetresPerSecond))/100
        let speedMPH = round(100 * (2.23694 * speedMetresPerSecond))/100
        let speedString = "\(preferences.storedPreferences[0].usingMetric ? speedKMH : speedMPH) " + speedUnits
        return speedString
    }
}

struct BikeRidesListView_Previews: PreviewProvider {
    static var previews: some View {
        BikeRidesListView()
    }
}

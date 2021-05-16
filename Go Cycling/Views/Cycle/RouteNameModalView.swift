//
//  RouteNameModalView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-05-15.
//

import SwiftUI

struct RouteNameModalView: View {
    let persistenceController = PersistenceController.shared

    @Environment(\.managedObjectContext) private var managedObjectContext
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showModally = true
    @State private var selectedNameIndex = 0
    @State private var namedRoutesViewSelection = NamedRoutesViewSelection.new
    
    @State private var typedRouteName: String = ""
    
    @ObservedObject var routeNamingViewModel = RouteNamingViewModel()
    
    private var bikeRideToEdit: BikeRide?
    
    init(bikeRideToEdit: BikeRide?) {
        if (bikeRideToEdit != nil) {
            self.bikeRideToEdit = bikeRideToEdit
        }
    }
    
    var body: some View {
        VStack {
            Text("Categorize Your Route")
                .font(.headline)
                .padding()
            
            Picker("Prefered Units", selection: $namedRoutesViewSelection) {
                Text("Create a New Category").tag(NamedRoutesViewSelection.new)
                Text("Use an Existing Category").tag(NamedRoutesViewSelection.existing)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(EdgeInsets.init(top: 0, leading: 10, bottom: 10, trailing: 10))
            
            switch namedRoutesViewSelection {
            case .new:
                Text("Enter your new category name")
                    
                TextField("Category Name", text: $typedRouteName)
                    .border(Color(UIColor.separator))
                    .padding()
                Spacer()
                Divider()
                Button (action: {self.presentationMode.wrappedValue.dismiss()}) {
                    Text("Cancel")
                        .foregroundColor(Color.red)
                }
                .padding()
                Divider()
                Button (action: {self.savePressed()}) {
                    Text("Save")
                        .bold()
                }
                .disabled(!((self.typedRouteName.count > 0)))
                .padding()
                Divider()
            case .existing:
                if (routeNamingViewModel.routeNames.count > 0) {
                    List {
                        ForEach(0 ..< routeNamingViewModel.routeNames.count) { index in
                        Button(action: {
                            self.selectedNameIndex = index
                        }) {
                            HStack {
                                Text(self.routeNamingViewModel.routeNames[index])
                                Spacer()
                                if self.selectedNameIndex == index {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Color.blue)
                                }
                            }
                            .contentShape(Rectangle())
                            .foregroundColor(.primary)
                        }
                        }
                    }
                }
                else {
                    Text("There are no saved categories.")
                }
                Spacer()
                Divider()
                Button (action: {self.presentationMode.wrappedValue.dismiss()}) {
                    Text("Cancel")
                        .foregroundColor(Color.red)
                }
                .padding()
                Divider()
                Button (action: {self.savePressed()}) {
                    Text("Save")
                        .bold()
                }
                .padding()
                .disabled(!(self.routeNamingViewModel.routeNames.count > 0))
                Divider()
            }
        }
        .presentation(isModal: self.showModally) {
        }
        .onAppear {
            if (bikeRideToEdit != nil && bikeRideToEdit?.cyclingRouteName != "Unnamed") {
                self.selectedNameIndex = routeNamingViewModel.routeNames.firstIndex(of: bikeRideToEdit!.cyclingRouteName)!
            }
            else {
                self.selectedNameIndex = 0
            }
        }
    }
    
    func savePressed() {
        var routeName = ""
        switch namedRoutesViewSelection {
        case .new:
            routeName = typedRouteName
        case .existing:
            routeName = self.routeNamingViewModel.routeNames[self.selectedNameIndex]
        }
        
        // This means that we are in the Cycle tab
        if (self.bikeRideToEdit == nil) {
            // Get most recent bike ride
            let ride = self.routeNamingViewModel.allBikeRides[self.routeNamingViewModel.allBikeRides.count - 1]
            // Route name should be Unnamed at this point
            if (ride.cyclingRouteName == "Unnamed") {
                persistenceController.updateBikeRideRouteName(
                    existingBikeRide: ride,
                    latitudes: ride.cyclingLatitudes,
                    longitudes: ride.cyclingLongitudes,
                    speeds: ride.cyclingSpeeds,
                    distance: ride.cyclingDistance,
                    elevations: ride.cyclingElevations,
                    startTime: ride.cyclingStartTime,
                    time: ride.cyclingTime,
                    routeName: routeName)
            }
            self.presentationMode.wrappedValue.dismiss()
        }
        else {
            let ride = self.bikeRideToEdit!
            persistenceController.updateBikeRideRouteName(
                existingBikeRide: ride,
                latitudes: ride.cyclingLatitudes,
                longitudes: ride.cyclingLongitudes,
                speeds: ride.cyclingSpeeds,
                distance: ride.cyclingDistance,
                elevations: ride.cyclingElevations,
                startTime: ride.cyclingStartTime,
                time: ride.cyclingTime,
                routeName: routeName)
            self.presentationMode.wrappedValue.dismiss()
        }
    }
}

enum NamedRoutesViewSelection: String, CaseIterable, Identifiable {
    case new
    case existing

    var id: String { self.rawValue }
}

//struct RouteNameModalView_Previews: PreviewProvider {
//    static var previews: some View {
//        RouteNameModalView()
//    }
//}

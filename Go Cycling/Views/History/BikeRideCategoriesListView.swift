//
//  BikeRideCategoryListView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-05-15.
//

import SwiftUI

struct BikeRideCategoriesListView: View {
    let persistenceController = PersistenceController.shared
    
    @EnvironmentObject var preferences: PreferencesStorage
    
    @ObservedObject var bikeRideViewModel = BikeRideListViewModel()
    
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    @State private var showEditModal = false
      
    var body: some View {
        NavigationView {
            if (preferences.storedPreferences[0].namedRoutes) {
                if (bikeRideViewModel.categories.count > 0) {
                    List {
                        ForEach(bikeRideViewModel.categories) { category in
                            NavigationLink(destination: BikeRidesListView(categoryName: category.name == "All" ? "" : category.name)) {
                                VStack(spacing: 10) {
                                    HStack {
                                        Text(category.name)
                                            .font(.headline)
                                            .foregroundColor(Color(UserPreferences.convertColourChoiceToUIColor(colour: preferences.storedPreferences[0].colourChoiceConverted)))
                                        Spacer()
                                        Text("\(category.number)")
                                    }
                                }
                           }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            if (preferences.storedPreferences[0].namedRoutes && self.editEnabledCheck()) {
                                Button ("Edit") {
                                    self.showEditModal = true
                                }
                            }
                        }
                    }
                    .navigationBarTitle("Cycling History", displayMode: .automatic)
                }
                else {
                    VStack {
                        Spacer()
                        Text("No completed routes to display!")
                        Spacer()
                    }
                    .navigationBarTitle("Cycling History", displayMode: .automatic)
                }
            }
            else {
                if (bikeRideViewModel.bikeRides.count > 0) {
                    BikeRidesListView(categoryName: "")
                }
                else {
                    VStack {
                        Spacer()
                        Text("No completed routes to display!")
                        Spacer()
                    }
                    .navigationBarTitle("Cycling History", displayMode: .automatic)
                }
            }
        }
        // Keep sheet outside of navigation view to avoid unexpected behaviour
        .sheet(isPresented: $showEditModal) {
            RouteRenameModalView(showEditModal: $showEditModal, names: bikeRideViewModel.categories)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func editEnabledCheck() -> Bool {
        if (bikeRideViewModel.categories.count > 2) {
            return true
        }
        else if (bikeRideViewModel.categories.count > 1) {
            if (bikeRideViewModel.categories[0].name == "All" && bikeRideViewModel.categories[1].name == "Uncategorized") {
                return false
            }
            return true
        }
        else {
            return false
        }
    }
}

struct BikeRideCategoryListView_Previews: PreviewProvider {
    static var previews: some View {
        BikeRideCategoriesListView()
    }
}

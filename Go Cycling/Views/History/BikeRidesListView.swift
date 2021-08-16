//
//  BikeRidesList.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-23.
//

import SwiftUI
import CoreLocation
import CoreData

struct BikeRidesListView: View {
    let persistenceController = PersistenceController.shared
    
    @EnvironmentObject var preferences: PreferencesStorage
    
    @ObservedObject var bikeRideViewModel = BikeRideListViewModel()
    
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    @State private var showingActionSheet = false
    @State private var showingFilterSheet = false
    @State private var showingPopover = false
    @State private var showingFilterPopover = false
    @State private var showingDeleteAlert = false
    @State private var shouldBeDeleted = false
    @State private var showingEditSheet = false
    @State private var toBeDeleted: IndexSet?
    @State private var sortChoice: SortChoice = .dateDescending
    @State private var selectedName: String = ""
    
    init() {
        self.selectedName = bikeRideViewModel.currentName
    }
    
    @State var sortDescriptor = NSSortDescriptor(keyPath: \BikeRide.cyclingTime, ascending: false)
    
    var body: some View {
        NavigationView {
            GeometryReader { (geometry) in
                ListView(sortDescripter: sortDescriptor, name: bikeRideViewModel.currentName, showingDeleteAlert: $showingDeleteAlert, shouldBeDeleted: $shouldBeDeleted)
                .listStyle(PlainListStyle())
                    .navigationBarTitle(self.getNavigationBarTitle(name: bikeRideViewModel.currentName), displayMode: .automatic)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        if (preferences.storedPreferences[0].namedRoutes && bikeRideViewModel.bikeRides.count > 0) {
                            Button (bikeRideViewModel.getFilterActionSheetTitle()) {
                                self.showingFilterSheet = true
                            }
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        if (preferences.storedPreferences[0].namedRoutes && bikeRideViewModel.editEnabledCheck()) {
                            Button ("Edit") {
                                self.showingEditSheet = true
                            }
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button (bikeRideViewModel.getActionSheetTitle()) {
                            if (min(geometry.size.width, geometry.size.height) < 600) {
                                self.showingActionSheet = true
                            }
                            else {
                                showingPopover.toggle()
                            }
                        }
                        .popover(isPresented: $showingPopover) {
                            BikeRideSortPopoverView(showingPopover: $showingPopover, sortChoice: $sortChoice)
                        }
                    }
                }
                .onAppear {
                    switch bikeRideViewModel.currentSortChoice {
                    case .distanceAscending:
                        sortDescriptor = NSSortDescriptor(keyPath: \BikeRide.cyclingDistance, ascending: true)
                    case .distanceDescending:
                        sortDescriptor = NSSortDescriptor(keyPath: \BikeRide.cyclingDistance, ascending: false)
                    case .dateAscending:
                        sortDescriptor = NSSortDescriptor(keyPath: \BikeRide.cyclingStartTime, ascending: true)
                    case .dateDescending:
                        sortDescriptor = NSSortDescriptor(keyPath: \BikeRide.cyclingStartTime, ascending: false)
                    case .timeAscending:
                        sortDescriptor = NSSortDescriptor(keyPath: \BikeRide.cyclingTime, ascending: true)
                    case .timeDescending:
                        sortDescriptor = NSSortDescriptor(keyPath: \BikeRide.cyclingTime, ascending: false)
                    }
                    sortChoice = bikeRideViewModel.currentSortChoice
                }
                // Filter action sheet
                .sheet(isPresented: $showingFilterSheet, content: {
                    BikeRideFilterSheetView(showingSheet: $showingFilterSheet, selectedName: $selectedName, names: bikeRideViewModel.categories)
                })
                // Edit sheet
                .sheet(isPresented: $showingEditSheet) {
                    RouteRenameModalView(showEditModal: $showingEditSheet, names: bikeRideViewModel.categories)
                }
                // Sort action sheet
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
                    switch bikeRideViewModel.currentSortChoice {
                    case .distanceAscending:
                        sortDescriptor = NSSortDescriptor(keyPath: \BikeRide.cyclingDistance, ascending: true)
                    case .distanceDescending:
                        sortDescriptor = NSSortDescriptor(keyPath: \BikeRide.cyclingDistance, ascending: false)
                    case .dateAscending:
                        sortDescriptor = NSSortDescriptor(keyPath: \BikeRide.cyclingStartTime, ascending: true)
                    case .dateDescending:
                        sortDescriptor = NSSortDescriptor(keyPath: \BikeRide.cyclingStartTime, ascending: false)
                    case .timeAscending:
                        sortDescriptor = NSSortDescriptor(keyPath: \BikeRide.cyclingTime, ascending: true)
                    case .timeDescending:
                        sortDescriptor = NSSortDescriptor(keyPath: \BikeRide.cyclingTime, ascending: false)
                    }
                    persistenceController.updateUserPreferences(
                        existingPreferences: preferences.storedPreferences[0],
                        unitsChoice: preferences.storedPreferences[0].metricsChoiceConverted,
                        displayingMetrics: preferences.storedPreferences[0].displayingMetrics,
                        colourChoice: preferences.storedPreferences[0].colourChoiceConverted,
                        largeMetrics: preferences.storedPreferences[0].largeMetrics,
                        sortChoice: bikeRideViewModel.currentSortChoice,
                        deletionConfirmation: preferences.storedPreferences[0].deletionConfirmation,
                        deletionEnabled: preferences.storedPreferences[0].deletionEnabled,
                        iconIndex: preferences.storedPreferences[0].iconIndex,
                        namedRoutes: preferences.storedPreferences[0].namedRoutes,
                        selectedRoute: preferences.storedPreferences[0].selectedRoute)
                })
                .onChange(of: sortChoice, perform: { value in
                    switch sortChoice {
                    case .distanceAscending:
                        bikeRideViewModel.sortByDistanceAscending()
                    case .distanceDescending:
                        bikeRideViewModel.sortByDistanceDescending()
                    case .dateAscending:
                        bikeRideViewModel.sortByDateAscending()
                    case .dateDescending:
                        bikeRideViewModel.sortByDateDescending()
                    case .timeAscending:
                        bikeRideViewModel.sortByTimeAscending()
                    case .timeDescending:
                        bikeRideViewModel.sortByTimeDescending()
                    }
                })
                .onChange(of: selectedName, perform: { value in
                    print("Selected name changed to \(selectedName)")
                    bikeRideViewModel.setCurrentName(name: selectedName)
                })
                .onChange(of: bikeRideViewModel.currentName, perform: { value in
                    persistenceController.updateUserPreferences(
                        existingPreferences: preferences.storedPreferences[0],
                        unitsChoice: preferences.storedPreferences[0].metricsChoiceConverted,
                        displayingMetrics: preferences.storedPreferences[0].displayingMetrics,
                        colourChoice: preferences.storedPreferences[0].colourChoiceConverted,
                        largeMetrics: preferences.storedPreferences[0].largeMetrics,
                        sortChoice: preferences.storedPreferences[0].sortingChoiceConverted,
                        deletionConfirmation: preferences.storedPreferences[0].deletionConfirmation,
                        deletionEnabled: preferences.storedPreferences[0].deletionEnabled,
                        iconIndex: preferences.storedPreferences[0].iconIndex,
                        namedRoutes: preferences.storedPreferences[0].namedRoutes,
                        selectedRoute: bikeRideViewModel.currentName)
                })
            }
        }
        // Move alert outside of navigation view due to a SwiftUI bug
        .alert(isPresented: $showingDeleteAlert) {
            Alert(title: Text("Are you sure that you want to delete this route?"),
                  message: Text("This action is not reversible."),
                  primaryButton: .destructive(Text("Delete")) {
                    self.shouldBeDeleted = true
                  },
                  secondaryButton: .cancel() {
                    self.shouldBeDeleted = false
                  }
            )
        }
    }
    
    func getNavigationBarTitle(name: String) -> String {
        if (preferences.storedPreferences[0].namedRoutes) {
            return (name == "") ? "Cycling History" : name
        }
        else {
            return "Cycling History"
        }
    }
}

struct ListView: View {
    let persistenceController = PersistenceController.shared
    
    @EnvironmentObject var preferences: PreferencesStorage
    
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    @Binding private var showingDeleteAlert: Bool
    @Binding private var shouldBeDeleted: Bool
    
    @State private var toBeDeleted: IndexSet?
    
    @FetchRequest var bikeRides: FetchedResults<BikeRide>

    init(sortDescripter: NSSortDescriptor, name: String, showingDeleteAlert: Binding<Bool>, shouldBeDeleted: Binding<Bool>) {
        let request: NSFetchRequest<BikeRide> = BikeRide.fetchRequest()
        if (name != "") {
            request.predicate = NSPredicate(format: "cyclingRouteName == %@", name)
        }
        request.sortDescriptors = [sortDescripter]
        _bikeRides = FetchRequest<BikeRide>(fetchRequest: request)
        self._showingDeleteAlert = showingDeleteAlert
        self._shouldBeDeleted = shouldBeDeleted
    }

    var body: some View {
        if (bikeRides.count > 0) {
            List {
                ForEach(bikeRides) { bikeRide in
                    NavigationLink(destination: SingleBikeRideView(bikeRide: bikeRide, navigationTitle: MetricsFormatting.formatDate(date: bikeRide.cyclingStartTime))) {
                        VStack(spacing: 10) {
                            HStack {
                                Text(MetricsFormatting.formatDate(date: bikeRide.cyclingStartTime))
                                    .font(.headline)
                                    .foregroundColor(Color(UserPreferences.convertColourChoiceToUIColor(colour: preferences.storedPreferences[0].colourChoiceConverted)))
                                Spacer()
                            }
                            HStack {
                                Text("Distance Cycled")
                                Spacer()
                                Text(MetricsFormatting.formatDistance(distance: bikeRide.cyclingDistance, usingMetric: preferences.storedPreferences[0].usingMetric))
                                    .font(.headline)
                            }
                            HStack {
                                Text("Cycling Time")
                                Spacer()
                                Text(MetricsFormatting.formatTime(time: bikeRide.cyclingTime))
                                    .font(.headline)
                            }
                            HStack {
                                Text("Average Speed")
                                Spacer()
                                Text(MetricsFormatting.formatAverageSpeed(distance: bikeRide.cyclingDistance, time: bikeRide.cyclingTime, usingMetric: preferences.storedPreferences[0].usingMetric))
                                    .font(.headline)
                            }
                        }
                    }
                }
                .onDelete(perform: preferences.storedPreferences[0].deletionEnabled ?  self.showDeleteAlert : nil)
                .onChange(of: shouldBeDeleted, perform: { value in
                    if (shouldBeDeleted == true) {
                        self.deleteBikeRide(at: self.toBeDeleted!)
                        self.toBeDeleted = nil
                    }
                })
            }
        }
        else {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text("No completed routes to display!")
                    Spacer()
                }
                Spacer()
            }
        }
    }
    
    func showDeleteAlert(at indexSet: IndexSet) {
        // Show alert
        if (preferences.storedPreferences[0].deletionConfirmation && preferences.storedPreferences[0].deletionEnabled) {
            self.showingDeleteAlert = true
            self.toBeDeleted = indexSet
        }
        // Delete without alert
        else if (preferences.storedPreferences[0].deletionEnabled) {
            deleteBikeRide(at: indexSet)
        }
    }
    
    func deleteBikeRide(at indexSet: IndexSet) {
        self.shouldBeDeleted = false
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

struct BikeRidesListView_Previews: PreviewProvider {
    static var previews: some View {
        BikeRidesListView()
    }
}

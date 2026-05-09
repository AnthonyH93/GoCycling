//
//  BikeRidesList.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-23.
//

import SwiftUI
import CoreLocation
import CoreData

struct BikeRideListView: View {
    let persistenceController = PersistenceController.shared
    
    @EnvironmentObject var preferences: Preferences
    
    @ObservedObject var bikeRideViewModel = BikeRideListViewModel()
    
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    @State private var showingDeleteAlert = false
    @State private var shouldBeDeleted = false
    @State private var showingSheet = false
    @State private var sheetToPresent: SheetToPresent = .filter
    @State private var updateCategories = false
    @State private var toBeDeleted: IndexSet?
    @State private var selectedName: String = Preferences.storedSelectedRoute()
    
    let telemetryManager = TelemetryManager.sharedTelemetryManager
    let telemetryTab = TelemetryTab.History
    
    var body: some View {
        NavigationView {
            GeometryReader { (geometry) in
                ListView(sortDescripter: bikeRideViewModel.getSortDescriptor(), name: bikeRideViewModel.currentName, showingDeleteAlert: $showingDeleteAlert, shouldBeDeleted: $shouldBeDeleted, updateCategories: $updateCategories)
                .listStyle(.plain)
                    .navigationBarTitle(self.getNavigationBarTitle(name: bikeRideViewModel.currentName), displayMode: .automatic)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        if (preferences.namedRoutes && bikeRideViewModel.filterEnabledCheck()) {
                            Button {
                                self.sheetToPresent = .filter
                                self.showingSheet = true

                                telemetryManager.sendCyclingSignal(
                                    tab: telemetryTab,
                                    action: TelemetryCyclingAction.FilterClick
                                )
                            } label: {
                                Image(systemName: "line.3.horizontal.decrease")
                            }
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        if (preferences.namedRoutes && bikeRideViewModel.editEnabledCheck()) {
                            Button {
                                self.sheetToPresent = .edit
                                self.showingSheet = true

                                telemetryManager.sendCyclingSignal(
                                    tab: telemetryTab,
                                    action: TelemetryCyclingAction.EditCategory
                                )
                            } label: {
                                Image(systemName: "pencil")
                            }
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu(bikeRideViewModel.getSortActionSheetTitle()) {
                            Button("Date Descending (Default)", action: bikeRideViewModel.sortByDateDescending)
                            Button("Date Ascending", action: bikeRideViewModel.sortByDateAscending)
                            Button("Distance Descending", action: bikeRideViewModel.sortByDistanceDescending)
                            Button("Distance Ascending", action: bikeRideViewModel.sortByDistanceAscending)
                            Button("Time Descending", action: bikeRideViewModel.sortByTimeDescending)
                            Button("Time Ascending", action: bikeRideViewModel.sortByTimeAscending)
                        }
                    }
                }
                .onAppear {
                    bikeRideViewModel.updateCategories()
                }
                .sheet(isPresented: $showingSheet, onDismiss: {
                    bikeRideViewModel.updateCategories()
                }, content: {
                    switch sheetToPresent {
                    case .filter:
                        BikeRideFilterSheetView(showingSheet: $showingSheet, selectedName: $selectedName, names: bikeRideViewModel.categories)
                    case .edit:
                        RouteRenameModalView(showEditModal: $showingSheet, names: bikeRideViewModel.categories)
                    }
                })
                .onChange(of: bikeRideViewModel.currentSortChoice, perform: { _ in
                    preferences.updateStringPreference(preference: CustomizablePreferences.sortingChoice, value: bikeRideViewModel.currentSortChoice.rawValue)
                    
                    telemetryManager.sendCyclingSignal(
                        tab: telemetryTab,
                        action: TelemetryCyclingAction.SortApply
                    )
                })
                .onChange(of: selectedName, perform: { _ in
                    bikeRideViewModel.setCurrentName(name: selectedName)
                })
                .onChange(of: bikeRideViewModel.currentName, perform: { _ in
                    preferences.updateStringPreference(preference: CustomizablePreferences.selectedRoute, value: bikeRideViewModel.currentName)
                })
                .onChange(of: updateCategories, perform: { _ in
                    /* For iOS 15 */
                    if #available(iOS 15, *) {
                        bikeRideViewModel.updateCategories()
                    }
                })
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
        // Move alert outside of navigation view due to a SwiftUI bug
        .alert(isPresented: $showingDeleteAlert) {
            Alert(title: Text("Are you sure that you want to delete this route?"),
                  message: Text("This action is not reversible."),
                  primaryButton: .destructive(Text("Delete")) {
                    self.shouldBeDeleted = true
                
                    telemetryManager.sendCyclingSignal(
                        tab: telemetryTab,
                        action: TelemetryCyclingAction.Delete
                    )
                  },
                  secondaryButton: .cancel() {
                    self.shouldBeDeleted = false
                  }
            )
        }
    }
    
    func getNavigationBarTitle(name: String) -> String {
        if (preferences.namedRoutes) {
            return (name == "") ? "Cycling History" : name
        }
        else {
            return "Cycling History"
        }
    }
}

struct ListView: View {
    let persistenceController = PersistenceController.shared
    
    @EnvironmentObject var preferences: Preferences
    
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    @Binding private var showingDeleteAlert: Bool
    @Binding private var shouldBeDeleted: Bool
    @Binding private var updateCategories: Bool
    
    @State private var toBeDeleted: IndexSet?
    
    @FetchRequest var bikeRides: FetchedResults<BikeRide>

    init(sortDescripter: NSSortDescriptor, name: String, showingDeleteAlert: Binding<Bool>, shouldBeDeleted: Binding<Bool>, updateCategories: Binding<Bool>) {
        let request: NSFetchRequest<BikeRide> = BikeRide.fetchRequest()
        if (name != "") {
            request.predicate = NSPredicate(format: "cyclingRouteName == %@", name)
        }
        request.sortDescriptors = [sortDescripter]
        _bikeRides = FetchRequest<BikeRide>(fetchRequest: request)
        self._showingDeleteAlert = showingDeleteAlert
        self._shouldBeDeleted = shouldBeDeleted
        self._updateCategories = updateCategories
    }

    var body: some View {
        if (bikeRides.count > 0) {
            List {
                ForEach(bikeRides) { bikeRide in
                    NavigationLink(destination: SingleBikeRideView(bikeRide: bikeRide, navigationTitle: MetricsFormatting.formatDate(date: bikeRide.cyclingStartTime))) {
                        // Bike ride list cell
                        VStack(spacing: 10) {
                            HStack {
                                Text(MetricsFormatting.formatDate(date: bikeRide.cyclingStartTime))
                                    .font(.headline)
                                    .foregroundColor(Color(UserPreferences.convertColourChoiceToUIColor(colour: preferences.colourChoiceConverted)))
                                Spacer()
                                Text(MetricsFormatting.formatStartTime(date: bikeRide.cyclingStartTime))
                                    .font(.headline)
                                    .foregroundColor(Color(UserPreferences.convertColourChoiceToUIColor(colour: preferences.colourChoiceConverted)))
                            }
                            HStack {
                                Text("Distance Cycled")
                                Spacer()
                                Text(MetricsFormatting.formatDistance(distance: bikeRide.cyclingDistance, usingMetric: preferences.usingMetric))
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
                                Text(MetricsFormatting.formatAverageSpeed(speeds: bikeRide.cyclingSpeeds, distance: bikeRide.cyclingDistance, time: bikeRide.cyclingTime, usingMetric: preferences.usingMetric))
                                    .font(.headline)
                            }
                        }
                    }
                }
                .onDelete(perform: preferences.deletionEnabled ?  self.showDeleteAlert : nil)
                .onChange(of: shouldBeDeleted, perform: { _ in
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
        if (preferences.deletionConfirmation && preferences.deletionEnabled) {
            self.showingDeleteAlert = true
            self.toBeDeleted = indexSet
        }
        // Delete without alert
        else if (preferences.deletionEnabled) {
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
            updateCategories.toggle()
        } catch {
            print(error.localizedDescription)
        }
    }

}

// To decide which sheet to present
enum SheetToPresent: String, CaseIterable, Identifiable {
    case filter
    case edit

    var id: String { self.rawValue }
}

struct BikeRideListView_Previews: PreviewProvider {
    static var previews: some View {
        BikeRideListView()
    }
}

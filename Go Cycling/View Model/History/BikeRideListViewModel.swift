//
//  BikeRideListViewModel.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-25.
//

import Foundation
import SwiftUI
import CoreData

class BikeRideListViewModel: ObservableObject {

    @Published var bikeRides: [BikeRide] = BikeRide.allBikeRidesSorted()
    @Published var categories: [Category] = BikeRide.allCategories()
    @Published var currentSortChoice: SortChoice = Preferences.storedSortingChoice()
    @Published var currentName: String = Preferences.storedSelectedRoute()
    
    init() {
        let valid = validateCategory(name: currentName)
        if (valid == false) {
            currentName = ""
        }
    }
    
    // This is the default ordering
    func sortByDateDescending() {
        bikeRides = BikeRide.sortByDate(list: bikeRides, ascending: false)
        currentSortChoice = .dateDescending
    }
    
    func sortByDateAscending() {
        bikeRides = BikeRide.sortByDate(list: bikeRides, ascending: true)
        currentSortChoice = .dateAscending
    }
    
    func sortByDistanceDescending() {
        bikeRides = BikeRide.sortByDistance(list: bikeRides, ascending: false)
        currentSortChoice = .distanceDescending
    }
    
    func sortByDistanceAscending() {
        bikeRides = BikeRide.sortByDistance(list: bikeRides, ascending: true)
        currentSortChoice = .distanceAscending
    }
    
    func sortByTimeDescending() {
        bikeRides = BikeRide.sortByTime(list: bikeRides, ascending: false)
        currentSortChoice = .timeDescending
    }
    
    func sortByTimeAscending() {
        bikeRides = BikeRide.sortByTime(list: bikeRides, ascending: true)
        currentSortChoice = .timeAscending
    }
    
    func getSortActionSheetTitle() -> String {
        var title = ""
        switch currentSortChoice {
        case .distanceAscending:
            title = "Distance ↑"
        case .distanceDescending:
            title = "Distance ↓"
        case .dateAscending:
            title = "Date ↑"
        case .dateDescending:
            title = "Date ↓"
        case .timeAscending:
            title = "Time ↑"
        case .timeDescending:
            title = "Time ↓"
        }
        return title
    }
    
    func setCurrentName(name: String) {
        self.currentName = name
    }
    
    func getFilterActionSheetTitle() -> String {
        return "Filter"
    }
    
    func editEnabledCheck() -> Bool {
        if (self.categories.count > 2) {
            return true
        }
        else if (self.categories.count > 1) {
            if (self.categories[0].name == "All" && self.categories[1].name == "Uncategorized") {
                return false
            }
            return true
        }
        else {
            return false
        }
    }
    
    func filterEnabledCheck() -> Bool {
        if (self.categories.count > 0) {
            return true
        }
        return false
    }
    
    func validateCategory(name: String) -> Bool {
        var validName = false
        for category in categories {
            if (category.name == name) {
                validName = true
                break
            }
        }
        return validName
    }
    
    // Used to create the correctly ordered list of bike rides to display
    func getSortDescriptor() -> NSSortDescriptor {
        switch self.currentSortChoice {
            case .distanceAscending:
                return NSSortDescriptor(keyPath: \BikeRide.cyclingDistance, ascending: true)
            case .distanceDescending:
                return NSSortDescriptor(keyPath: \BikeRide.cyclingDistance, ascending: false)
            case .dateAscending:
                return NSSortDescriptor(keyPath: \BikeRide.cyclingStartTime, ascending: true)
            case .dateDescending:
                return NSSortDescriptor(keyPath: \BikeRide.cyclingStartTime, ascending: false)
            case .timeAscending:
                return NSSortDescriptor(keyPath: \BikeRide.cyclingTime, ascending: true)
            case .timeDescending:
                return NSSortDescriptor(keyPath: \BikeRide.cyclingTime, ascending: false)
        }
    }
    
    // Function to update categories
    func updateCategories() {
        categories = BikeRide.allCategories()
        let valid = validateCategory(name: currentName)
        if (valid == false) {
            currentName = ""
        }
    }
}

//
//  BikeRideListViewModel.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-25.
//

import Foundation
import SwiftUI

class BikeRideListViewModel: ObservableObject {

    @Published var bikeRides: [BikeRide] = BikeRide.allBikeRidesSorted()
    @Published var categories: [Category] = BikeRide.allCategories()
    @Published var currentSortChoice: SortChoice = UserPreferences.storedSortingChoice()
    @Published var currentName: String = UserPreferences.storedSelectedRoute()
    
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
}

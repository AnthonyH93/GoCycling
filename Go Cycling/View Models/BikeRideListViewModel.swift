//
//  BikeRideListViewModel.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-25.
//

import Foundation
import SwiftUI

class BikeRideListViewModel: ObservableObject {

    @Published var bikeRides: [BikeRide] = BikeRide.allBikeRides()
    @Published var currentSortType: SortType = .dateDescending
    
    // This is the default ordering
    func sortByDateDescending() {
        bikeRides = BikeRide.sortByDate(list: bikeRides, ascending: false)
        currentSortType = .dateDescending
    }
    
    func sortByDateAscending() {
        bikeRides = BikeRide.sortByDate(list: bikeRides, ascending: true)
        currentSortType = .dateAscending
    }
    
    func sortByDistanceDescending() {
        bikeRides = BikeRide.sortByDistance(list: bikeRides, ascending: false)
        currentSortType = .distanceDescending
    }
    
    func sortByDistanceAscending() {
        bikeRides = BikeRide.sortByDistance(list: bikeRides, ascending: true)
        currentSortType = .distanceAscending
    }
    
    func sortByTimeDescending() {
        bikeRides = BikeRide.sortByTime(list: bikeRides, ascending: false)
        currentSortType = .timeDescending
    }
    
    func sortByTimeAscending() {
        bikeRides = BikeRide.sortByTime(list: bikeRides, ascending: true)
        currentSortType = .timeAscending
    }
}

enum SortType: String, CaseIterable, Identifiable {
    case distanceAscending
    case distanceDescending
    case dateAscending
    case dateDescending
    case timeAscending
    case timeDescending

    var id: String { self.rawValue }
}


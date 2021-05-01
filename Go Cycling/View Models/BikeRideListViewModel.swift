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
    @Published var currentSortType: SortChoice = .dateDescending
    
//    func reSortList() {
//        let storedRides = BikeRide.allBikeRides()
//        print("Count inside: \(storedRides.count)")
//        print("Sort as: \(currentSortType)")
//        switch currentSortType {
//        case .distanceAscending:
//            bikeRides = BikeRide.sortByDistance(list: storedRides, ascending: true)
//        case .distanceDescending:
//            bikeRides = BikeRide.sortByDistance(list: storedRides, ascending: false)
//        case .dateAscending:
//            bikeRides = BikeRide.sortByDate(list: storedRides, ascending: true)
//        case .dateDescending:
//            bikeRides = BikeRide.sortByDate(list: storedRides, ascending: false)
//        case .timeAscending:
//            bikeRides = BikeRide.sortByTime(list: storedRides, ascending: true)
//        case .timeDescending:
//            bikeRides = BikeRide.sortByTime(list: storedRides, ascending: false)
//        }
//    }
    
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

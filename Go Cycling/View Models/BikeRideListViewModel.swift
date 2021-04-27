//
//  BikeRideListViewModel.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-25.
//

import Foundation
import SwiftUI

class BikeRideListViewModel: ObservableObject {
    
//    @FetchRequest(entity: BikeRide.entity(), sortDescriptors: [], predicate: nil)
//    var bikeRides: FetchedResults<BikeRide>
    
    //var unsortedBikeRides: [BikeRide]
    @Published var bikeRides: [BikeRide] = BikeRide.allBikeRides()
    
    func sortByDistance() {
        bikeRides = BikeRide.sortByDistance(list: bikeRides)
    }
}

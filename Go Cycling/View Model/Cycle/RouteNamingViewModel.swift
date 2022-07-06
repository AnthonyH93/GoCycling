//
//  RouteNamingViewModel.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-05-15.
//

import Foundation
import SwiftUI

class RouteNamingViewModel: ObservableObject {

    @Published var allBikeRides: [BikeRide] = BikeRide.allBikeRides()
    @Published var routeNames: [String] = BikeRide.allRouteNames()
    
}


//
//  UserPreferences.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-17.
//

import Foundation
import SwiftUI

class UserPreferences: ObservableObject {
    @Published var colour: Color
    @Published var usingMetric: Bool
    @Published var displayingMetrics: Bool
    
    init(colour: Color, usingMetric: Bool, displayingMetrics: Bool) {
        self.colour = colour
        self.usingMetric = usingMetric
        self.displayingMetrics = displayingMetrics
    }
}

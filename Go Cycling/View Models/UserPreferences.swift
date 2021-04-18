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
    
    init(colour: Color, usingMetric: Bool) {
        self.colour = colour
        self.usingMetric = usingMetric
    }
}

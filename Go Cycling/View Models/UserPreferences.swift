//
//  UserPreferences.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-17.
//

import Foundation
import SwiftUI

class UserPreferences: ObservableObject {
    @Published var colour: ColourChoice
    @Published var usingMetric: Bool
    @Published var displayingMetrics: Bool
    
    init(colour: ColourChoice, usingMetric: Bool, displayingMetrics: Bool) {
        self.colour = colour
        self.usingMetric = usingMetric
        self.displayingMetrics = displayingMetrics
    }
    
    final func convertColourChoiceToUIColor(colour: ColourChoice) -> UIColor {
        switch colour {
        case .red:
            return UIColor.systemRed
        case .orange:
            return UIColor.systemOrange
        case .yellow:
            return UIColor.systemYellow
        case .green:
            return UIColor.systemGreen
        case .blue:
            return UIColor.systemBlue
        case .indigo:
            return UIColor.systemIndigo
        case .violet:
            return UIColor.systemPurple
        }
    }

}

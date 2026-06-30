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
    
    static func convertColourChoiceToUIColor(colour: ColourChoice) -> UIColor {
        switch colour {
        case .red:      return .systemRed
        case .orange:   return .systemOrange
        case .yellow:   return .systemYellow
        case .green:    return .systemGreen
        case .blue:     return .systemBlue
        case .indigo:   return .systemIndigo
        case .violet:   return .systemPurple
        case .custom:
            if let hex = UserDefaults.standard.string(forKey: Preferences.customColourHexKey),
               let color = UIColor(hexRGB: hex) {
                return color
            }
            return .systemBlue
        }
    }

}

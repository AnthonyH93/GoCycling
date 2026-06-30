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

extension UIColor {
    convenience init?(hexRGB hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        guard cleaned.count == 6 else { return nil }
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)
        self.init(
            red:   CGFloat((value >> 16) & 0xFF) / 255,
            green: CGFloat((value >>  8) & 0xFF) / 255,
            blue:  CGFloat( value        & 0xFF) / 255,
            alpha: 1
        )
    }
}

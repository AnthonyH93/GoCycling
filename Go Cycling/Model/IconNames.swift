//
//  IconNames.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-05-02.
//

import Foundation
import SwiftUI

class IconNames: ObservableObject {
    var iconNames: [String?] = [nil]
    var iconNamesOrdered: [String?] = [nil]
    @Published var currentIndex = 0
    
    init() {
        getAlternateIconNames()
        getOrderedAlternateIconNames()
        
        if let currentIcon = UIApplication.shared.alternateIconName{
            self.currentIndex = iconNamesOrdered.firstIndex(of: currentIcon) ?? 0
        }
    }
    
    func getAlternateIconNames(){
        if let icons = Bundle.main.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any],
           let alternateIcons = icons["CFBundleAlternateIcons"] as? [String: Any] {
            for (_, value) in alternateIcons {
                guard let iconList = value as? Dictionary<String,Any> else{return}
                guard let iconFiles = iconList["CFBundleIconFiles"] as? [String]
                else{return}
                guard let icon = iconFiles.first else{return}
                iconNames.append(icon)
            }
        }
    }
    
    func getOrderedAlternateIconNames() {
        if (iconNames.count > 1) {
            let correctOrder = ["Default Inverted", "Dark", "Light", "Interstellar", "Interstellar Inverted", "Ocean", "Ocean Inverted",
                                "Sunset", "Sunset Inverted", "Bronze", "Bronze Inverted", "Silver", "Silver Inverted", "Gold", "Gold Inverted"]
            for (index, name) in correctOrder.enumerated() {
                if (iconNames.contains(correctOrder[index])) {
                    iconNamesOrdered.append(name)
                }
            }
        }
        else {
            return
        }
    }
    
    // To be used for the unlockable icons and getting the correct index in the ordered icon names array
    func getCorrectIndex(index: Int) -> Int {
        switch index {
        // Bronze Inverted
        case 11:
            return 0
        // Silver Inverted
        case 13:
            return 1
        // Gold Inverted
        case 15:
            return 2
        // Bronze
        case 10:
            return 3
        // Silver
        case 12:
            return 4
        // Gold
        case 14:
            return 5
        default:
            return 0
        }
    }
}

//
//  SavedPreferences+CoreDataClass.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-18.
//
//

import Foundation
import CoreData
import SwiftUI

@objc(UserPreferences)
public class UserPreferences: NSManagedObject {
    static func convertColourChoiceToUIColor(colour: ColourChoice) -> UIColor {
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

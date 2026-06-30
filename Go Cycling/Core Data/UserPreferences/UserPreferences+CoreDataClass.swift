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

extension UserPreferences {
    static func savedPreferences() -> UserPreferences? {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<UserPreferences> = UserPreferences.fetchRequest()
        do {
            let items = try context.fetch(fetchRequest)
            if items.count > 0 {
                return items[0]
            }
            else {
                return nil
            }
        }
        catch let error as NSError {
            print("Error getting UserPreferences: \(error.localizedDescription), \(error.userInfo)")
        }
        return nil
    }
}

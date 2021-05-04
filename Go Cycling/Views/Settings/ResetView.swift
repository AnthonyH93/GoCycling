//
//  ResetView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-05-04.
//

import SwiftUI

struct ResetView: View {
    let persistenceController = PersistenceController.shared
    
    @EnvironmentObject var preferences: PreferencesStorage
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    var body: some View {
        Button (action: {self.resetToDefaultSettings()}) {
            Text("Reset to Default Settings")
                .foregroundColor(Color(UserPreferences.convertColourChoiceToUIColor(colour: preferences.storedPreferences[0].colourChoiceConverted)))
        }
        Button (action: {self.deleteAllBikeRides()}) {
            Text("Delete All Stored Bike Rides")
                .foregroundColor(Color(UserPreferences.convertColourChoiceToUIColor(colour: preferences.storedPreferences[0].colourChoiceConverted)))
        }
    }
    
    func resetToDefaultSettings() {
        persistenceController.updateUserPreferences(
            existingPreferences: preferences.storedPreferences[0],
            unitsChoice: UnitsChoice.metric,
            displayingMetrics: true,
            colourChoice: ColourChoice.blue,
            largeMetrics: false,
            sortChoice: SortChoice.dateDescending)
    }
    
    func deleteAllBikeRides() {
        persistenceController.deleteAllBikeRides()
    }
}

struct ResetView_Previews: PreviewProvider {
    static var previews: some View {
        ResetView()
    }
}

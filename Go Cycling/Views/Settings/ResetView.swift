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
    
    @State var showingAlert = false
    
    var body: some View {
        Button (action: {self.resetToDefaultSettings()}) {
            Text("Reset to Default Settings")
                .foregroundColor(Color(UserPreferences.convertColourChoiceToUIColor(colour: preferences.storedPreferences[0].colourChoiceConverted)))
        }
        Button (action: {self.showDeleteAlert()}) {
            Text("Delete All Stored Bike Rides")
                .foregroundColor(Color(UserPreferences.convertColourChoiceToUIColor(colour: preferences.storedPreferences[0].colourChoiceConverted)))
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Are you sure that you want to delete all stored bike rides?"),
                  message: Text("This action is not reversible."),
                  primaryButton: .destructive(Text("Delete")) {
                    self.deleteAllBikeRides()
                  },
                  secondaryButton: .cancel()
            )
        }
    }
    
    func showDeleteAlert() {
        self.showingAlert = true
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

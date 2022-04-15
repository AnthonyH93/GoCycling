//
//  ResetView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-05-04.
//

import SwiftUI

struct ResetView: View {
    let persistenceController = PersistenceController.shared
    
    @EnvironmentObject var preferences: Preferences
    @EnvironmentObject var records: RecordsStorage
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    @State var showingDeleteAlert = false
    @State var showingResetToDefaultAlert = false
    @State var showingResetStatisticsAlert = false
    
    var body: some View {
        Button (action: {self.showResetToDefaultAlert()}) {
            Text("Reset to Default Settings")
                .foregroundColor(Color(UserPreferences.convertColourChoiceToUIColor(colour: preferences.colourChoiceConverted)))
        }
        .alert(isPresented: $showingResetToDefaultAlert) {
            Alert(title: Text("Are you sure that you want to reset to the default settings?"),
                  message: Text("This action will return your app to the factory settings."),
                  primaryButton: .destructive(Text("Reset")) {
                    self.resetToDefaultSettings()
                  },
                  secondaryButton: .cancel()
            )
        }
        Button (action: {self.showDeleteAlert()}) {
            Text("Delete All Stored Routes")
                .foregroundColor(Color(UserPreferences.convertColourChoiceToUIColor(colour: preferences.colourChoiceConverted)))
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(title: Text("Are you sure that you want to delete all stored cycling routes?"),
                  message: Text("This action is not reversible."),
                  primaryButton: .destructive(Text("Delete")) {
                    self.deleteAllBikeRides()
                  },
                  secondaryButton: .cancel()
            )
        }
        Button (action: {self.showResetStatisticsAlert()}) {
            Text("Reset Stored Statistics")
                .foregroundColor(Color(UserPreferences.convertColourChoiceToUIColor(colour: preferences.colourChoiceConverted)))
        }
        .alert(isPresented: $showingResetStatisticsAlert) {
            Alert(title: Text("Are you sure that you want to reset all stored statistics?"),
                  message: Text("This action is not reversible."),
                  primaryButton: .destructive(Text("Reset")) {
                    self.resetStoredStatistics()
                  },
                  secondaryButton: .cancel()
            )
        }
    }
    
    func showDeleteAlert() {
        self.showingDeleteAlert = true
    }
    
    func showResetToDefaultAlert() {
        self.showingResetToDefaultAlert = true
    }
    
    func showResetStatisticsAlert() {
        self.showingResetStatisticsAlert = true
    }
    
    func resetToDefaultSettings() {
        preferences.resetPreferences()
    }
    
    func deleteAllBikeRides() {
        persistenceController.deleteAllBikeRides()
    }
    
    func resetStoredStatistics() {
        // Reset to default records
        persistenceController.updateRecords(
            existingRecords: records.storedRecords[0],
            totalDistance: 0.0,
            totalTime: 0.0,
            totalRoutes: 0,
            longestDistance: 0.0,
            longestTime: 0.0,
            fastestAvgSpeed: 0.0,
            longestDistanceDate: nil,
            longestTimeDate: nil,
            fastestAvgSpeedDate: nil)
    }
}

struct ResetView_Previews: PreviewProvider {
    static var previews: some View {
        ResetView()
    }
}

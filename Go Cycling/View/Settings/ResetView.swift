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
    @EnvironmentObject var records: CyclingRecords
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    @State var showingDeleteAlert = false
    @State var showingResetToDefaultAlert = false
    @State var showingResetStatisticsAlert = false

    #if DEBUG
    @State var showingGenerateSampleDataAlert = false
    @State var generatingSampleData = false
    @State var generatedSampleRideCount: Int? = nil
    #endif

    // Access singleton TelemetryManager class object
    let telemetryManager = TelemetryManager.sharedTelemetryManager
    let telemetryTabSection = TelemetrySettingsSection.Reset
    
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
        #if DEBUG
        Button (action: {self.showingGenerateSampleDataAlert = true}) {
            HStack {
                Text(generatingSampleData ? "Generating Sample Data..." : "Generate Sample Data")
                    .foregroundColor(Color(UserPreferences.convertColourChoiceToUIColor(colour: preferences.colourChoiceConverted)))
                Spacer()
                if let count = generatedSampleRideCount {
                    Text("\(count) rides")
                        .foregroundColor(.secondary)
                }
            }
        }
        .disabled(generatingSampleData)
        .alert(isPresented: $showingGenerateSampleDataAlert) {
            Alert(title: Text("Generate two years of sample rides?"),
                  message: Text("Debug builds only. This deletes all stored routes and statistics first, and the generated rides will sync to iCloud if this device is signed in."),
                  primaryButton: .destructive(Text("Generate")) {
                    self.generateSampleData()
                  },
                  secondaryButton: .cancel()
            )
        }
        #endif
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
        
        telemetryManager.sendSettingsSignal(
            section: telemetryTabSection,
            action: TelemetrySettingsAction.Defaults
        )
    }
    
    func deleteAllBikeRides() {
        persistenceController.deleteAllBikeRides()
        
        telemetryManager.sendSettingsSignal(
            section: telemetryTabSection,
            action: TelemetrySettingsAction.DeleteRoutes
        )
    }
    
    func resetStoredStatistics() {
        // Reset to default records
        CyclingRecords.resetStatistics()
        
        telemetryManager.sendSettingsSignal(
            section: telemetryTabSection,
            action: TelemetrySettingsAction.DeleteStats
        )
    }

    #if DEBUG
    // Debug only - fills the app with a plausible cycling history for App Store screenshots.
    // Deliberately sends no telemetry so screenshot runs don't show up in analytics.
    func generateSampleData() {
        self.generatingSampleData = true
        self.generatedSampleRideCount = nil

        SampleDataGenerator.generate { count in
            self.generatedSampleRideCount = count
            self.generatingSampleData = false
        }
    }
    #endif
}

struct ResetView_Previews: PreviewProvider {
    static var previews: some View {
        ResetView()
    }
}

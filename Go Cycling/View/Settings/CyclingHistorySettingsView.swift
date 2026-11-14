//
//  CyclingHistorySettingsView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-05-06.
//

import SwiftUI

struct CyclingHistorySettingsView: View {
    let persistenceController = PersistenceController.shared
    
    @EnvironmentObject var preferences: Preferences
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    // Access singleton TelemetryManager class object
    let telemetryManager = TelemetryManager.sharedTelemetryManager
    let telemetryTabSection = TelemetrySettingsSection.History

    @State private var isExporting = false
    @State private var exportedFiles: ExportedFiles? = nil
    @State private var exportAlertMessage: String? = nil
    @State private var importAlertMessage: String? = nil

    var body: some View {
        Toggle("Ride Categorization Enabled", isOn: Binding(
            get: { preferences.namedRoutes },
            set: { value in
                preferences.updateBoolPreference(preference: CustomizablePreferences.namedRoutes, value: value)
                telemetryManager.sendSettingsSignal(section: telemetryTabSection, action: TelemetrySettingsAction.RoutesEnabled)
            }
        ))
        Toggle("Deletion Enabled", isOn: Binding(
            get: { preferences.deletionEnabled },
            set: { value in
                preferences.updateBoolPreference(preference: CustomizablePreferences.deletionEnabled, value: value)
                telemetryManager.sendSettingsSignal(section: telemetryTabSection, action: TelemetrySettingsAction.DeletionEnabled)
            }
        ))
        Toggle("Deletion Confirmation Alert", isOn: Binding(
            get: { preferences.deletionConfirmation },
            set: { value in
                preferences.updateBoolPreference(preference: CustomizablePreferences.deletionConfirmation, value: value)
                telemetryManager.sendSettingsSignal(section: telemetryTabSection, action: TelemetrySettingsAction.DeletionConfirmtion)
            }
        ))
        Button(action: { exportAllRides() }) {
            HStack {
                Text("Export All Rides as GPX")
                Spacer()
                if isExporting {
                    ProgressView()
                }
            }
        }
        .disabled(isExporting)
        .sheet(item: $exportedFiles) { files in
            ActivityViewController(activityItems: files.urls)
        }
        .alert(isPresented: Binding(
            get: { exportAlertMessage != nil },
            set: { if !$0 { exportAlertMessage = nil } }
        )) {
            Alert(title: Text("GPX Export"), message: Text(exportAlertMessage ?? ""), dismissButton: .default(Text("OK")))
        }
        ImportGPXButton(
            onImportStarted: {
                telemetryManager.sendSettingsSignal(section: telemetryTabSection, action: TelemetrySettingsAction.ImportGPX)
            },
            onImportFinished: { message in
                importAlertMessage = message
            }
        ) { isImporting in
            HStack {
                Text("Import Rides from GPX")
                Spacer()
                if isImporting {
                    ProgressView()
                }
            }
        }
        .alert(isPresented: Binding(
            get: { importAlertMessage != nil },
            set: { if !$0 { importAlertMessage = nil } }
        )) {
            Alert(title: Text("GPX Import"), message: Text(importAlertMessage ?? ""), dismissButton: .default(Text("OK")))
        }
    }

    func exportAllRides() {
        isExporting = true
        telemetryManager.sendSettingsSignal(section: telemetryTabSection, action: TelemetrySettingsAction.ExportAllGPX)

        GPXExporter.exportAllRides(container: persistenceController.container) { result in
            isExporting = false
            switch result {
            case .success(let urls):
                if urls.isEmpty {
                    exportAlertMessage = "There are no saved rides to export."
                } else {
                    exportedFiles = ExportedFiles(urls: urls)
                }
            case .failure(let error):
                print("GPX export failed: \(error.localizedDescription)")
                exportAlertMessage = "Your rides could not be exported. Please try again."
            }
        }
    }
}

struct CyclingHistorySettingsView_Previews: PreviewProvider {
    static var previews: some View {
        CyclingHistorySettingsView()
    }
}

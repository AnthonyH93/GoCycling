//
//  ChangeAppIconView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-05-02.
//
//  App icon changing logic found at https://betterprogramming.pub/how-to-change-your-apps-icon-in-swiftui-1f2ff3c44344

import SwiftUI

struct ChangeAppIconView: View {
    let persistenceController = PersistenceController.shared
    
    @EnvironmentObject var iconNames: IconNames
    @EnvironmentObject var preferences: PreferencesStorage
    @EnvironmentObject var records: RecordsStorage
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    var body: some View {
        if (self.iconNames.iconNames.count > 3) {
            Picker("App Icon", selection: $preferences.storedPreferences[0].iconIndex) {
                ForEach (0..<self.iconNames.iconNamesOrdered.count) { index in
                    if (index < 6 || records.storedRecords[0].unlockedIcons[index - 6]) {
                        Text(self.iconNames.iconNamesOrdered[index] ?? "Default").tag(index)
                    }
                    else {
                        EmptyView().tag(index)
                    }
                }
                .navigationBarTitle("Choose your App Icon", displayMode: .inline)
            }
            .onChange(of: preferences.storedPreferences[0].iconIndex) { value in

                let index = self.iconNames.iconNamesOrdered.firstIndex(of: UIApplication.shared.alternateIconName) ?? 0

                if index != value {
                    UIApplication.shared.setAlternateIconName(self.iconNames.iconNamesOrdered[preferences.storedPreferences[0].iconIndex]) { error in
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            // Save new choice to device
                            persistenceController.updateUserPreferences(
                                existingPreferences: preferences.storedPreferences[0],
                                unitsChoice: preferences.storedPreferences[0].metricsChoiceConverted,
                                displayingMetrics: preferences.storedPreferences[0].displayingMetrics,
                                colourChoice: preferences.storedPreferences[0].colourChoiceConverted,
                                largeMetrics: preferences.storedPreferences[0].largeMetrics,
                                sortChoice: preferences.storedPreferences[0].sortingChoiceConverted,
                                deletionConfirmation: preferences.storedPreferences[0].deletionConfirmation,
                                deletionEnabled: preferences.storedPreferences[0].deletionEnabled,
                                iconIndex: preferences.storedPreferences[0].iconIndex,
                                namedRoutes: preferences.storedPreferences[0].namedRoutes,
                                selectedRoute: preferences.storedPreferences[0].selectedRoute)
                            print("Changed app icon successfully.")
                        }
                    }
                }
            }
        }
    }
}

struct ChangeAppIconView_Previews: PreviewProvider {
    static var previews: some View {
        ChangeAppIconView()
    }
}

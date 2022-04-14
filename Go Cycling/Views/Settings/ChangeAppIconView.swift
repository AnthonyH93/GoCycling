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
    @EnvironmentObject var newPreferences: Preferences
    @EnvironmentObject var records: RecordsStorage
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    var body: some View {
        if (self.iconNames.iconNames.count > 3) {
            Picker("App Icon", selection: $newPreferences.iconIndex) {
                ForEach (0..<self.iconNames.iconNamesOrdered.count) { index in
                    if (index < 10 || records.storedRecords[0].unlockedIcons[iconNames.getCorrectIndex(index: index)]) {
                        HStack {
                            Image(self.iconNames.iconNamesOrdered[index] ?? "Default")
                                .cornerRadius(15)
                            Text(self.iconNames.iconNamesOrdered[index] ?? "Default").tag(index)
                        }
                    }
                    else {
                        EmptyView().tag(index)
                    }
                }
                .navigationBarTitle("Choose your App Icon", displayMode: .inline)
            }
            .onChange(of: newPreferences.iconIndex) { value in

                let index = self.iconNames.iconNamesOrdered.firstIndex(of: UIApplication.shared.alternateIconName) ?? 0

                if index != value {
                    UIApplication.shared.setAlternateIconName(self.iconNames.iconNamesOrdered[newPreferences.iconIndex]) { error in
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            // Save new choice to device
                            newPreferences.updateIntPreference(preference: CustomizablePreferences.iconIndex, value: newPreferences.iconIndex)
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

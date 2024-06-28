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
    @EnvironmentObject var preferences: Preferences
    @EnvironmentObject var records: CyclingRecords
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    var body: some View {
        if (self.iconNames.iconNames.count > 3) {
            // The picker view within a form changed in iOS 16
            if #available(iOS 16.0, *) {
                Picker("App Icon", selection: $preferences.iconIndex) {
                    ForEach (0..<self.iconNames.iconNamesOrdered.count, id: \.self) { index in
                        if (index < 10 || records.unlockedIcons[iconNames.getCorrectIndex(index: index)]) {
                            HStack () {
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
                // Use the navigation link picker style (how it looked before iOS 16)
                .pickerStyle(.navigationLink)
                .onChange(of: preferences.iconIndex) { value in
                    self.changeAppIcon(value: value)
                }
            }
            else {
                Picker("App Icon", selection: $preferences.iconIndex) {
                    ForEach (0..<self.iconNames.iconNamesOrdered.count, id: \.self) { index in
                        if (index < 10 || records.unlockedIcons[iconNames.getCorrectIndex(index: index)]) {
                            HStack () {
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
                .onChange(of: preferences.iconIndex) { value in
                    self.changeAppIcon(value: value)
                }
            }
        }
    }
    
    // Function to call when the picker value is changed
    func changeAppIcon(value: Int) {
        // Changing app icon is a review worthy event
        ReviewManager.incrementReviewWorthyCount()
        
        let index = self.iconNames.iconNamesOrdered.firstIndex(of: UIApplication.shared.alternateIconName) ?? 0

        if index != value {
            UIApplication.shared.setAlternateIconName(self.iconNames.iconNamesOrdered[preferences.iconIndex]) { error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    // Save new choice to device
                    preferences.updateIntPreference(preference: CustomizablePreferences.iconIndex, value: preferences.iconIndex)
                    print("Changed app icon successfully.")
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

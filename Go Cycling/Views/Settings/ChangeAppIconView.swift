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
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    var body: some View {
        if (self.iconNames.iconNames.count > 3) {
            Picker("App Icon", selection: $iconNames.currentIndex) {
                // Need to manually set these icon names instead of programmatically due to SwiftUI bug with navigation titles
                Text(self.iconNames.iconNamesOrdered[0] ?? "Default").tag(0)
                Text(self.iconNames.iconNamesOrdered[1] ?? "Default").tag(1)
                Text(self.iconNames.iconNamesOrdered[2] ?? "Default").tag(2)
                Text(self.iconNames.iconNamesOrdered[3] ?? "Default").tag(3)
                    .navigationBarTitle("Choose your App Icon", displayMode: .inline)

            }
            .onReceive([self.iconNames.currentIndex].publisher.first()) { (value) in

                let index = self.iconNames.iconNamesOrdered.firstIndex(of: UIApplication.shared.alternateIconName) ?? 0

                if index != value {
                    UIApplication.shared.setAlternateIconName(self.iconNames.iconNamesOrdered[value]) { error in
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
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

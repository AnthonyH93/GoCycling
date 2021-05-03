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
        Picker("App Icon", selection: $iconNames.currentIndex) {
            ForEach(0..<iconNames.iconNames.count) {
                Text(self.iconNames.iconNames[$0] ?? "Default")
            }
        }
        .onReceive([self.iconNames.currentIndex].publisher.first()) { (value) in

            let index = self.iconNames.iconNames.firstIndex(of: UIApplication.shared.alternateIconName) ?? 0

            if index != value{
                UIApplication.shared.setAlternateIconName(self.iconNames.iconNames[value]){ error in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        print("Changed app icon successfully.")
                    }
                }
            }
        }
        .navigationBarTitle("Choose your App Icon", displayMode: .inline)
    }
}

struct ChangeAppIconView_Previews: PreviewProvider {
    static var previews: some View {
        ChangeAppIconView()
    }
}

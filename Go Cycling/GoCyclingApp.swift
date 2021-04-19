//
//  Go_CyclingApp.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-03-14.
//

import SwiftUI

@main
struct GoCyclingApp: App {
    
    let persistenceController = PersistenceController.shared
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject var preferences: PreferencesStorage
    
    init() {
        let managedObjectContext = persistenceController.container.viewContext
        let storage = PreferencesStorage(managedObjectContext: managedObjectContext)
        print(storage)
        self._preferences = StateObject(wrappedValue: storage)
    }

    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(preferences)
        }
        .onChange(of: scenePhase) { _ in
            persistenceController.save()
        }
    }
}

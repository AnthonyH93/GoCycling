//
//  Preferences.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2022-04-13.
//

import Foundation

// Enum to represent the configurable settings
enum CustomizablePreferences {
    case metric
    case displayingMetrics
    case colour
    case largeMetrics
    case sortingChoice
    case deletionConfirmation
    case deletionEnabled
    case iconIndex
    case namedRoutes
    case selectedRoute
    case iCloudSync
}

// Class to represent the preferences of a user
class Preferences: ObservableObject {
    
    // Singleton instance
    static let shared: Preferences = Preferences()
    
    @Published var usingMetric: Bool
    @Published var displayingMetrics: Bool
    @Published var colourChoice: String
    @Published var largeMetrics: Bool
    @Published var sortingChoice: String
    @Published var deletionConfirmation: Bool
    @Published var deletionEnabled: Bool
    @Published var iconIndex: Int
    @Published var namedRoutes: Bool
    @Published var selectedRoute: String
    @Published var iCloudOn: Bool
    
    static private let initKey = "didSetupPreferences"
    static private let keys = ["metric", "displayingMetrics", "colour", "largeMetrics", "sortingChoice", "deletionConfirmation", "deletionEnabled", "namedRoutes", "selectedRoute"]
    // Icon index is a special case since it should only be stored locally
    static private let iconIndexKey = "iconIndex"
    // iCloud sync setting is also only stored locally
    static private let iCloudOnKey = "iCloudOn"
    static private let keyTypes = [0, 0, 2, 0, 2, 0, 0, 0, 2] // 0: Bool, 1: Int, 2: String
    
    init() {
        // First check if iCloud is available
        let iCloudStatus = Preferences.iCloudAvailable()
        
        // Next check if preferences have ever been setup
        var status = Preferences.havePreferencesBeenInitialized()
        
        // On device only if iCloud is off
        if !iCloudStatus {
            if (UserDefaults.standard.object(forKey: Preferences.initKey) == nil) {
                status = 0
            }
            else {
                status = 1
            }
        }
        
        switch status {
        // Nothing is setup
        case 0:
            Preferences.writeDefaults(iCloud: false)
            UserDefaults.standard.set(true, forKey: Preferences.initKey)
            if iCloudStatus {
                Preferences.writeDefaults(iCloud: true)
                NSUbiquitousKeyValueStore.default.set(true, forKey: Preferences.initKey)
            }
        // On device is setup
        case 1:
            if iCloudStatus {
                Preferences.syncLocalAndCloud(localToCloud: true)
                NSUbiquitousKeyValueStore.default.set(true, forKey: Preferences.initKey)
            }
        // iCloud is setup
        case 2:
            if iCloudStatus {
                Preferences.syncLocalAndCloud(localToCloud: false)
                UserDefaults.standard.set(true, forKey: Preferences.initKey)
            }
        // Everything is setup
        case 3:
            if iCloudStatus {
                Preferences.syncLocalAndCloud(localToCloud: false)
            }
        default:
            fatalError("Index out of range")
        }
        
        // Set class attributes based on local copy of data
        self.usingMetric = UserDefaults.standard.bool(forKey: Preferences.keys[0])
        self.displayingMetrics = UserDefaults.standard.bool(forKey: Preferences.keys[1])
        self.colourChoice = UserDefaults.standard.string(forKey: Preferences.keys[2])!
        self.largeMetrics = UserDefaults.standard.bool(forKey: Preferences.keys[3])
        self.sortingChoice = UserDefaults.standard.string(forKey: Preferences.keys[4])!
        self.deletionConfirmation = UserDefaults.standard.bool(forKey: Preferences.keys[5])
        self.deletionEnabled = UserDefaults.standard.bool(forKey: Preferences.keys[6])
        self.namedRoutes = UserDefaults.standard.bool(forKey: Preferences.keys[7])
        self.selectedRoute = UserDefaults.standard.string(forKey: Preferences.keys[8])!
        
        self.iconIndex = UserDefaults.standard.integer(forKey: Preferences.iconIndexKey)
        self.iCloudOn = UserDefaults.standard.bool(forKey: Preferences.iCloudOnKey)
        
        // Used to watch for iCloud NSUbiquitousKeyValueStore change events to sync preferences from other devices
        NotificationCenter.default.addObserver(self, selector: #selector(keysDidChangeOnCloud(notification:)),
                                                       name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                                                       object: nil)
    }
    
    @objc func keysDidChangeOnCloud(notification: Notification) {
        // Force this update to run on the main thread, but asynchronously
        DispatchQueue.main.async {
            Preferences.syncLocalAndCloud(localToCloud: false)
            self.writeToClassMembers()
        }
    }
    
    // Converters for Views
    var colourChoiceConverted: ColourChoice {
        set {
            colourChoice = newValue.rawValue
        }
        get {
            ColourChoice(rawValue: colourChoice) ?? .blue
        }
    }
    
    var sortingChoiceConverted: SortChoice {
        set {
            sortingChoice = newValue.rawValue
        }
        get {
            SortChoice(rawValue: sortingChoice) ?? .dateDescending
        }
    }
    
    var metricsChoiceConverted: UnitsChoice {
        set {
            if (newValue.id == "metric") {
                usingMetric = true
            }
            else {
                usingMetric = false
            }
        }
        get {
            usingMetric ? .metric : .imperial
        }
    }
    
    // Function to update class members
    private func writeToClassMembers() {
        self.usingMetric = UserDefaults.standard.bool(forKey: Preferences.keys[0])
        self.displayingMetrics = UserDefaults.standard.bool(forKey: Preferences.keys[1])
        self.colourChoice = UserDefaults.standard.string(forKey: Preferences.keys[2])!
        self.largeMetrics = UserDefaults.standard.bool(forKey: Preferences.keys[3])
        self.sortingChoice = UserDefaults.standard.string(forKey: Preferences.keys[4])!
        self.deletionConfirmation = UserDefaults.standard.bool(forKey: Preferences.keys[5])
        self.deletionEnabled = UserDefaults.standard.bool(forKey: Preferences.keys[6])
        self.namedRoutes = UserDefaults.standard.bool(forKey: Preferences.keys[7])
        self.selectedRoute = UserDefaults.standard.string(forKey: Preferences.keys[8])!
        
        self.iconIndex = UserDefaults.standard.integer(forKey: Preferences.iconIndexKey)
        self.iCloudOn = UserDefaults.standard.bool(forKey: Preferences.iCloudOnKey)
    }
    
    static public func iCloudAvailable() -> Bool {
        // Set iCloud preference if it doesn't exist
        if UserDefaults.standard.object(forKey: Preferences.iCloudOnKey) == nil {
            UserDefaults.standard.set(false, forKey: Preferences.iCloudOnKey)
        }
        // Check if iCloud is available
        var iCloudAvailable = false
        if FileManager.default.ubiquityIdentityToken != nil {
            iCloudAvailable = true
        }
        if !UserDefaults.standard.bool(forKey: Preferences.iCloudOnKey) {
            iCloudAvailable = false
        }
        return iCloudAvailable
    }
    
    // 0: Nothing setup, 1: On device setup, 2: iCloud setup, 3: Both iCloud and on device setup
    static private func havePreferencesBeenInitialized() -> Int {
        if (!UserDefaults.standard.bool(forKey: initKey) && !NSUbiquitousKeyValueStore.default.bool(forKey: initKey)) {
            return 0
        }
        else if (UserDefaults.standard.bool(forKey: initKey) && !NSUbiquitousKeyValueStore.default.bool(forKey: initKey)) {
            return 1
        }
        else if (!UserDefaults.standard.bool(forKey: initKey) && NSUbiquitousKeyValueStore.default.bool(forKey: initKey)) {
            return 2
        }
        else {
            return 3
        }
    }
    
    static private func writeDefaults(iCloud: Bool) {
        // Use NSUbiquitousKeyValueStore for iCloud storage
        if iCloud {
            NSUbiquitousKeyValueStore.default.set(true, forKey: keys[0])
            NSUbiquitousKeyValueStore.default.set(true, forKey: keys[1])
            NSUbiquitousKeyValueStore.default.set(ColourChoice.blue.rawValue, forKey: keys[2])
            NSUbiquitousKeyValueStore.default.set(false, forKey: keys[3])
            NSUbiquitousKeyValueStore.default.set(SortChoice.dateDescending.rawValue, forKey: keys[4])
            NSUbiquitousKeyValueStore.default.set(true, forKey: keys[5])
            NSUbiquitousKeyValueStore.default.set(true, forKey: keys[6])
            NSUbiquitousKeyValueStore.default.set(true, forKey: keys[7])
            NSUbiquitousKeyValueStore.default.set("", forKey: keys[8])
        }
        // Use UserDefaults for local storage
        else {
            UserDefaults.standard.set(true, forKey: keys[0])
            UserDefaults.standard.set(true, forKey: keys[1])
            UserDefaults.standard.set(ColourChoice.blue.rawValue, forKey: keys[2])
            UserDefaults.standard.set(false, forKey: keys[3])
            UserDefaults.standard.set(SortChoice.dateDescending.rawValue, forKey: keys[4])
            UserDefaults.standard.set(true, forKey: keys[5])
            UserDefaults.standard.set(true, forKey: keys[6])
            UserDefaults.standard.set(true, forKey: keys[7])
            UserDefaults.standard.set("", forKey: keys[8])
        }
        
        // Store iconIndex locally in either case
        UserDefaults.standard.set(0, forKey: iconIndexKey)
    }
    
    static private func syncLocalAndCloud(localToCloud: Bool) {
        // Only sync if available
        if Preferences.iCloudAvailable() {
            // Sync local to cloud
            if localToCloud {
                for (i, k) in keys.enumerated() {
                    switch keyTypes[i] {
                    // Integer
                    case 1:
                        NSUbiquitousKeyValueStore.default.set(UserDefaults.standard.integer(forKey: k), forKey: k)
                    // String
                    case 2:
                        NSUbiquitousKeyValueStore.default.set(UserDefaults.standard.string(forKey: k)!, forKey: k)
                    // Bool
                    default:
                        NSUbiquitousKeyValueStore.default.set(UserDefaults.standard.bool(forKey: k), forKey: k)
                        print("LOCAL 2 CLOUD \(k) \(UserDefaults.standard.bool(forKey: k))")
                    }
                }
                NSUbiquitousKeyValueStore.default.synchronize()
            }
            // Sync cloud to local
            else {
                for (i, k) in keys.enumerated() {
                    switch keyTypes[i] {
                    // Integer
                    case 1:
                        UserDefaults.standard.set(NSUbiquitousKeyValueStore.default.object(forKey: k) as! Int, forKey: k)
                    // String
                    case 2:
                        UserDefaults.standard.set(NSUbiquitousKeyValueStore.default.string(forKey: k)!, forKey: k)
                    // Bool
                    default:
                        UserDefaults.standard.set(NSUbiquitousKeyValueStore.default.bool(forKey: k), forKey: k)
                        print("CLOUD 2 LOCAL \(k) \(UserDefaults.standard.bool(forKey: k))")
                    }
                }
            }
        }
    }
    
    // Should only ever be called once - used to migrate legacy UserPreferences to UserDefaults and NSUbiquitousKeyValueStore
    public func initialUserPreferencesMigration(existingPreferences: UserPreferences) {
        UserDefaults.standard.set(existingPreferences.usingMetric, forKey: Preferences.keys[0])
        UserDefaults.standard.set(existingPreferences.displayingMetrics, forKey: Preferences.keys[1])
        UserDefaults.standard.set(existingPreferences.colourChoice, forKey: Preferences.keys[2])
        UserDefaults.standard.set(existingPreferences.largeMetrics, forKey: Preferences.keys[3])
        UserDefaults.standard.set(existingPreferences.sortingChoice, forKey: Preferences.keys[4])
        UserDefaults.standard.set(existingPreferences.deletionConfirmation, forKey: Preferences.keys[5])
        UserDefaults.standard.set(existingPreferences.deletionEnabled, forKey: Preferences.keys[6])
        UserDefaults.standard.set(existingPreferences.namedRoutes, forKey: Preferences.keys[7])
        UserDefaults.standard.set(existingPreferences.selectedRoute, forKey: Preferences.keys[8])
        
        UserDefaults.standard.set(existingPreferences.iconIndex, forKey: Preferences.iconIndexKey)
        
        // Default iCloud to OFF
        UserDefaults.standard.set(false, forKey: Preferences.iCloudOnKey)
        
        UserDefaults.standard.set(true, forKey: Preferences.initKey)
        
        self.writeToClassMembers()
    }
    
    // To be called when an update of a preference is needed
    public func updateBoolPreference(preference: CustomizablePreferences, value: Bool) {
        switch preference {
        case .metric:
            UserDefaults.standard.set(value, forKey: Preferences.keys[0])
            self.usingMetric = value
        case .displayingMetrics:
            UserDefaults.standard.set(value, forKey: Preferences.keys[1])
            self.displayingMetrics = value
        case .largeMetrics:
            UserDefaults.standard.set(value, forKey: Preferences.keys[3])
            self.largeMetrics = value
        case .deletionConfirmation:
            UserDefaults.standard.set(value, forKey: Preferences.keys[5])
            self.deletionConfirmation = value
        case .deletionEnabled:
            UserDefaults.standard.set(value, forKey: Preferences.keys[6])
            self.deletionEnabled = value
        case .namedRoutes:
            UserDefaults.standard.set(value, forKey: Preferences.keys[7])
            self.namedRoutes = value
        case .iCloudSync:
            // Special case for turning on iCloud
            UserDefaults.standard.set(value, forKey: Preferences.iCloudOnKey)
            self.iCloudOn = value
            // Check if iCloud has been setup
            let status = Preferences.havePreferencesBeenInitialized()
            if (status == 3 && value) {
                Preferences.syncLocalAndCloud(localToCloud: false)
                self.writeToClassMembers()
            }
        default:
            fatalError("Incorrect parameter for preference")
        }
        
        // Update iCloud data
        Preferences.syncLocalAndCloud(localToCloud: true)
    }
    
    public func updateStringPreference(preference: CustomizablePreferences, value: String) {
        switch preference {
        case .colour:
            UserDefaults.standard.set(value, forKey: Preferences.keys[2])
            self.colourChoice = value
        case .sortingChoice:
            UserDefaults.standard.set(value, forKey: Preferences.keys[4])
            self.sortingChoice = value
        case .selectedRoute:
            UserDefaults.standard.set(value, forKey: Preferences.keys[8])
            self.selectedRoute = value
        default:
            fatalError("Incorrect parameter for preference")
        }
        
        // Update iCloud data
        Preferences.syncLocalAndCloud(localToCloud: true)
    }
    
    public func updateIntPreference(preference: CustomizablePreferences, value: Int) {
        switch preference {
        case .iconIndex:
            UserDefaults.standard.set(value, forKey: Preferences.iconIndexKey)
            self.iconIndex = value
        default:
            fatalError("Incorrect parameter for preference")
        }
    }
    
    // For the reset to default settings button on the settings tab
    public func resetPreferences() {
        Preferences.writeDefaults(iCloud: false)
        Preferences.syncLocalAndCloud(localToCloud: true)
        self.writeToClassMembers()
    }
    
    // Used in BikeRideViewModel where the environment object is not available
    static func storedSortingChoice() -> SortChoice {
        let stringValue = UserDefaults.standard.string(forKey: Preferences.keys[4])!

        return SortChoice(rawValue: stringValue) ?? SortChoice.dateDescending
    }
    
    static func storedSelectedRoute() -> String {
        return UserDefaults.standard.string(forKey: Preferences.keys[8])!
    }
}

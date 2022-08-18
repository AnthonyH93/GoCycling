//
//  Records.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2022-04-15.
//

import Foundation
import MapKit

// Class to represent the cycling records of a user
class CyclingRecords: ObservableObject {
    
    // Singleton instance
    static let shared: CyclingRecords = CyclingRecords()
    
    @Published var totalCyclingTime: Double
    @Published var totalCyclingRoutes: Int
    @Published var unlockedIcons: [Bool]
    @Published var longestCyclingDistance: Double
    @Published var longestCyclingTime: Double
    @Published var fastestAverageSpeed: Double
    @Published var fastestAverageSpeedDate: Date?
    @Published var longestCyclingDistanceDate: Date?
    @Published var longestCyclingTimeDate: Date?
    // Total cycling distance is always changed last as the ActivityAwardsViewModel publishes changes when it changes
    @Published var totalCyclingDistance: Double
    
    static private let initKey = "didSetupRecords"
    static private let keys = ["totalCyclingTime", "totalCyclingDistance", "unlockedIcons", "longestCyclingDistance", "longestCyclingTime", "fastestAverageSpeed", "fastestAverageSpeedDate", "longestCyclingDistanceDate", "longestCyclingTimeDate", "totalCyclingRoutes"]
    static private let keyTypes = [2, 2, 0, 2, 2, 2, 3, 3, 3, 1] // 0: [Bool], 1: Int, 2: Double, 3: Date
    
    static private let numberOfUnlockableIcons = 6
    static let awardValues: [Double] = [10.0 * 1000, 25.0 * 1000, 50.0 * 1000, 100.0 * 1000, 250.0 * 1000, 500.0 * 1000]
    
    init() {
        // First check if iCloud is available
        let iCloudStatus = Preferences.iCloudAvailable()
        
        // Next check if records have ever been setup
        let status = CyclingRecords.haveCyclingRecordsBeenInitialized()
        
        switch status {
        // Nothing is setup
        case 0:
            CyclingRecords.writeDefaults(iCloud: false)
            UserDefaults.standard.set(true, forKey: CyclingRecords.initKey)
            if iCloudStatus {
                CyclingRecords.writeDefaults(iCloud: true)
                NSUbiquitousKeyValueStore.default.set(true, forKey: CyclingRecords.initKey)
            }
        // On device is setup
        case 1:
            if iCloudStatus {
                CyclingRecords.syncLocalAndCloud(localToCloud: true)
                NSUbiquitousKeyValueStore.default.set(true, forKey: CyclingRecords.initKey)
            }
        // iCloud is setup
        case 2:
            if iCloudStatus {
                CyclingRecords.syncLocalAndCloud(localToCloud: false)
                UserDefaults.standard.set(true, forKey: CyclingRecords.initKey)
            }
        // Everything is setup
        case 3:
            if iCloudStatus {
                CyclingRecords.syncLocalAndCloud(localToCloud: false)
            }
        default:
            fatalError("Index out of range")
        }
        
        // Set class attributes based on local copy of data
        self.totalCyclingTime = UserDefaults.standard.double(forKey: CyclingRecords.keys[0])
        self.totalCyclingDistance = UserDefaults.standard.double(forKey: CyclingRecords.keys[1])
        self.unlockedIcons = UserDefaults.standard.array(forKey: CyclingRecords.keys[2]) as! [Bool]
        self.longestCyclingDistance = UserDefaults.standard.double(forKey: CyclingRecords.keys[3])
        self.longestCyclingTime = UserDefaults.standard.double(forKey: CyclingRecords.keys[4])
        self.fastestAverageSpeed = UserDefaults.standard.double(forKey: CyclingRecords.keys[5])
        self.fastestAverageSpeedDate = UserDefaults.standard.object(forKey: CyclingRecords.keys[6]) as? Date
        self.longestCyclingDistanceDate = UserDefaults.standard.object(forKey: CyclingRecords.keys[7]) as? Date
        self.longestCyclingTimeDate = UserDefaults.standard.object(forKey: CyclingRecords.keys[8]) as? Date
        self.totalCyclingRoutes = UserDefaults.standard.integer(forKey: CyclingRecords.keys[9])
        
        // Used to watch for iCloud NSUbiquitousKeyValueStore change events to sync records from other devices
        NotificationCenter.default.addObserver(self, selector: #selector(keysDidChangeOnCloud(notification:)),
                                                       name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                                                       object: nil)
    }
    
    @objc func keysDidChangeOnCloud(notification: Notification) {
        // Force this update to run on the main thread, but asynchronously
        DispatchQueue.main.async {
            CyclingRecords.syncLocalAndCloud(localToCloud: false)
            self.writeToClassMembers()
        }
    }
    
    private func writeToClassMembers() {
        self.totalCyclingTime = UserDefaults.standard.double(forKey: CyclingRecords.keys[0])
        self.totalCyclingDistance = UserDefaults.standard.double(forKey: CyclingRecords.keys[1])
        self.unlockedIcons = UserDefaults.standard.array(forKey: CyclingRecords.keys[2]) as! [Bool]
        self.longestCyclingDistance = UserDefaults.standard.double(forKey: CyclingRecords.keys[3])
        self.longestCyclingTime = UserDefaults.standard.double(forKey: CyclingRecords.keys[4])
        self.fastestAverageSpeed = UserDefaults.standard.double(forKey: CyclingRecords.keys[5])
        self.fastestAverageSpeedDate = UserDefaults.standard.object(forKey: CyclingRecords.keys[6]) as? Date
        self.longestCyclingDistanceDate = UserDefaults.standard.object(forKey: CyclingRecords.keys[7]) as? Date
        self.longestCyclingTimeDate = UserDefaults.standard.object(forKey: CyclingRecords.keys[8]) as? Date
        self.totalCyclingRoutes = UserDefaults.standard.integer(forKey: CyclingRecords.keys[9])
    }
    
    // 0: Nothing setup, 1: On device setup, 2: iCloud setup, 3: Both iCloud and on device setup
    static private func haveCyclingRecordsBeenInitialized() -> Int {
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
            NSUbiquitousKeyValueStore.default.set(0.0, forKey: keys[0])
            NSUbiquitousKeyValueStore.default.set(0.0, forKey: keys[1])
            NSUbiquitousKeyValueStore.default.set([Bool].init(repeating: false, count: numberOfUnlockableIcons), forKey: keys[2])
            NSUbiquitousKeyValueStore.default.set(0.0, forKey: keys[3])
            NSUbiquitousKeyValueStore.default.set(0.0, forKey: keys[4])
            NSUbiquitousKeyValueStore.default.set(0.0, forKey: keys[5])
            NSUbiquitousKeyValueStore.default.set(0, forKey: keys[9])
        }
        // Use UserDefaults for local storage
        else {
            UserDefaults.standard.set(0.0, forKey: keys[0])
            UserDefaults.standard.set(0.0, forKey: keys[1])
            UserDefaults.standard.set([Bool].init(repeating: false, count: numberOfUnlockableIcons), forKey: keys[2])
            UserDefaults.standard.set(0.0, forKey: keys[3])
            UserDefaults.standard.set(0.0, forKey: keys[4])
            UserDefaults.standard.set(0.0, forKey: keys[5])
            UserDefaults.standard.set(0, forKey: keys[9])
        }
    }
    
    // Function to write class members to UserDefaults (used when updating the CyclingRecords after a new completed bike ride)
    private func writeClassMembersToUserDefaults() {
        UserDefaults.standard.set(self.totalCyclingTime, forKey: CyclingRecords.keys[0])
        UserDefaults.standard.set(self.totalCyclingDistance, forKey: CyclingRecords.keys[1])
        UserDefaults.standard.set(self.unlockedIcons, forKey: CyclingRecords.keys[2])
        UserDefaults.standard.set(self.longestCyclingDistance, forKey: CyclingRecords.keys[3])
        UserDefaults.standard.set(self.longestCyclingTime, forKey: CyclingRecords.keys[4])
        UserDefaults.standard.set(self.fastestAverageSpeed, forKey: CyclingRecords.keys[5])
        
        if let date = self.fastestAverageSpeedDate {
            UserDefaults.standard.set(date, forKey: CyclingRecords.keys[6])
        }
        if let date = self.longestCyclingDistanceDate {
            UserDefaults.standard.set(date, forKey: CyclingRecords.keys[7])
        }
        if let date = self.longestCyclingTimeDate {
            UserDefaults.standard.set(date, forKey: CyclingRecords.keys[8])
        }
        
        UserDefaults.standard.set(self.totalCyclingRoutes, forKey: CyclingRecords.keys[9])
    }
    
    static private func syncLocalAndCloud(localToCloud: Bool) {
        // Sync local to cloud
        if localToCloud {
            for (i, k) in keys.enumerated() {
                switch keyTypes[i] {
                // Integer
                case 1:
                    NSUbiquitousKeyValueStore.default.set(UserDefaults.standard.integer(forKey: k), forKey: k)
                // Double
                case 2:
                    NSUbiquitousKeyValueStore.default.set(UserDefaults.standard.double(forKey: k), forKey: k)
                // Date?
                case 3:
                    if let date = UserDefaults.standard.object(forKey: k) as? Date {
                        NSUbiquitousKeyValueStore.default.set(date, forKey: k)
                    }
                // [Bool]
                default:
                    NSUbiquitousKeyValueStore.default.set(UserDefaults.standard.array(forKey: k) as! [Bool], forKey: k)
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
                // Double
                case 2:
                    UserDefaults.standard.set(NSUbiquitousKeyValueStore.default.double(forKey: k), forKey: k)
                // Date?
                case 3:
                    if let date = NSUbiquitousKeyValueStore.default.object(forKey: k) as? Date {
                        UserDefaults.standard.set(date, forKey: k)
                    }
                // [Bool]
                default:
                    UserDefaults.standard.set(NSUbiquitousKeyValueStore.default.array(forKey: k) as! [Bool], forKey: k)
                }
            }
        }
    }
    
    // Should only ever be called once - used to migrate legacy Records to UserDefaults and NSUbiquitousKeyValueStore or create Records from existing BikeRides
    public func initialRecordsMigration(existingRecords: Records?, existingBikeRides: [BikeRide]) {
        if let records = existingRecords {
            UserDefaults.standard.set(records.totalCyclingTime, forKey: CyclingRecords.keys[0])
            UserDefaults.standard.set(records.totalCyclingDistance, forKey: CyclingRecords.keys[1])
            UserDefaults.standard.set(records.unlockedIcons, forKey: CyclingRecords.keys[2])
            UserDefaults.standard.set(records.longestCyclingDistance, forKey: CyclingRecords.keys[3])
            UserDefaults.standard.set(records.longestCyclingTime, forKey: CyclingRecords.keys[4])
            UserDefaults.standard.set(records.fastestAverageSpeed, forKey: CyclingRecords.keys[5])
            
            if let date = records.fastestAverageSpeedDate {
                UserDefaults.standard.set(date, forKey: CyclingRecords.keys[6])
            }
            if let date = records.longestCyclingDistanceDate {
                UserDefaults.standard.set(date, forKey: CyclingRecords.keys[7])
            }
            if let date = records.longestCyclingTimeDate {
                UserDefaults.standard.set(date, forKey: CyclingRecords.keys[8])
            }
            
            UserDefaults.standard.set(Int(records.totalCyclingRoutes), forKey: CyclingRecords.keys[9])
        }
        else {
            if existingBikeRides.count > 0 {
                let values = Records.getDefaultRecordsValues(bikeRides: existingBikeRides)
                
                UserDefaults.standard.set(values.totalTime, forKey: CyclingRecords.keys[0])
                UserDefaults.standard.set(values.totalDistance, forKey: CyclingRecords.keys[1])
                UserDefaults.standard.set(values.unlockedIcons, forKey: CyclingRecords.keys[2])
                UserDefaults.standard.set(values.longestDistance, forKey: CyclingRecords.keys[3])
                UserDefaults.standard.set(values.longestTime, forKey: CyclingRecords.keys[4])
                UserDefaults.standard.set(values.fastestAvgSpeed, forKey: CyclingRecords.keys[5])
                
                if let date = values.fastestAvgSpeedDate {
                    UserDefaults.standard.set(date, forKey: CyclingRecords.keys[6])
                }
                if let date = values.longestDistanceDate {
                    UserDefaults.standard.set(date, forKey: CyclingRecords.keys[7])
                }
                if let date = values.longestTimeDate {
                    UserDefaults.standard.set(date, forKey: CyclingRecords.keys[8])
                }
                
                UserDefaults.standard.set(Int(values.totalRoutes), forKey: CyclingRecords.keys[9])
            }
        }
        
        // Sync to iCloud
        CyclingRecords.syncLocalAndCloud(localToCloud: true)
        
        // Update class members
        self.writeToClassMembers()
    }
    
    // Updates CyclingRecords after a new bike ride has been completed
    public func updateCyclingRecords(speeds: [CLLocationSpeed?], distance: Double, startTime: Date, time: Double) {
        self.totalCyclingDistance = self.totalCyclingDistance + distance
        self.totalCyclingTime = self.totalCyclingTime + time
        self.longestCyclingDistanceDate = distance > self.longestCyclingDistance ? startTime : self.longestCyclingDistanceDate
        self.longestCyclingDistance = max(distance, self.longestCyclingDistance)
        self.longestCyclingTimeDate = time > self.longestCyclingTime ? startTime : self.longestCyclingTimeDate
        self.longestCyclingTime = max(time, self.longestCyclingTime)
        
        var bestAvgSpeed: Double = self.fastestAverageSpeed
        var bestAvgSpeedDate: Date? = self.fastestAverageSpeedDate
        let speedsValidated = speeds.compactMap { $0 }
        // Only count fastest average speed if route was 1 KM or longer
        if (speedsValidated.count > 0 && distance > 999) {
            let maxSpeed = speedsValidated.max()
            let avgSpeed = distance/time
            // Must be a valid average speed
            if (maxSpeed ?? 0.0 >= avgSpeed && avgSpeed > self.fastestAverageSpeed) {
                bestAvgSpeed = avgSpeed
                bestAvgSpeedDate = startTime
            }
        }
        
        self.fastestAverageSpeed = bestAvgSpeed
        self.fastestAverageSpeedDate = bestAvgSpeedDate
        
        self.totalCyclingRoutes = self.totalCyclingRoutes + 1
        
        // Update UserDefaults
        self.writeClassMembersToUserDefaults()
        
        CyclingRecords.syncLocalAndCloud(localToCloud: true)
        
        // Update unlocked icons
        self.updateUnlockedIcons()
    }
    
    // Determines unlocked icons bool array based on class members
    public func updateUnlockedIcons() {
        var newUnlockedIcons = [Bool].init(repeating: false, count: CyclingRecords.numberOfUnlockableIcons)
        var change = false
        
        for index in 0..<self.unlockedIcons.count {
            // Leave as true if already set
            if self.unlockedIcons[index] == true {
                newUnlockedIcons[index] = true
                continue
            }
            else {
                // Indexes 0-2 are for individual ride distance records
                if (index < 3) {
                    if (self.longestCyclingDistance >= CyclingRecords.awardValues[index]) {
                        self.unlockedIcons[index] = true
                        newUnlockedIcons[index] = true
                        change = true
                    }
                }
                // Indexes 3-5 are for total distance records
                else {
                    if (self.totalCyclingDistance >= CyclingRecords.awardValues[index]) {
                        self.unlockedIcons[index] = true
                        newUnlockedIcons[index] = true
                        change = true
                    }
                }
            }
        }
        
        // Save if there is a change
        if change {
            self.writeClassMembersToUserDefaults()
            // Sync to iCloud
            CyclingRecords.syncLocalAndCloud(localToCloud: true)
        }
    }
    
    // Reset stored statistics (except unlocked app icons)
    static public func resetStatistics() {
        // Local
        UserDefaults.standard.set(0.0, forKey: keys[0])
        UserDefaults.standard.set(0.0, forKey: keys[1])
        UserDefaults.standard.set(0.0, forKey: keys[3])
        UserDefaults.standard.set(0.0, forKey: keys[4])
        UserDefaults.standard.set(0.0, forKey: keys[5])
        // Need to be explicit about removing these as setting them to nil isn't going to work (the Date? typed records)
        UserDefaults.standard.removeObject(forKey: keys[6])
        UserDefaults.standard.removeObject(forKey: keys[7])
        UserDefaults.standard.removeObject(forKey: keys[8])
        
        UserDefaults.standard.set(0, forKey: keys[9])
        
        // iCloud
        NSUbiquitousKeyValueStore.default.set(0.0, forKey: keys[0])
        NSUbiquitousKeyValueStore.default.set(0.0, forKey: keys[1])
        NSUbiquitousKeyValueStore.default.set(0.0, forKey: keys[3])
        NSUbiquitousKeyValueStore.default.set(0.0, forKey: keys[4])
        NSUbiquitousKeyValueStore.default.set(0.0, forKey: keys[5])
        // Need to be explicit about removing these as setting them to nil isn't going to work (the Date? typed records)
        NSUbiquitousKeyValueStore.default.removeObject(forKey: keys[6])
        NSUbiquitousKeyValueStore.default.removeObject(forKey: keys[7])
        NSUbiquitousKeyValueStore.default.removeObject(forKey: keys[8])
        
        NSUbiquitousKeyValueStore.default.set(0, forKey: keys[9])
        
        // Update class members
        CyclingRecords.shared.writeToClassMembers()
    }
}

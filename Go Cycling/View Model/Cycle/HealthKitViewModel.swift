//
//  HealthKitViewModel.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2024-07-03.
//

import Foundation
import HealthKit
import WidgetKit

class HealthKitManager: ObservableObject {
    
    // A singleton for the entire app - there should be only 1 instance of this class
    static let healthKitManager = HealthKitManager()
    
    var healthStore = HKHealthStore()
    
//    init() {
//        requestAuthorization()
//    }
    
    func requestAuthorization() {
        // Set the types of data we would like to write
        let dataToShare = Set([
            HKObjectType.quantityType(forIdentifier: .distanceCycling)!
        ])
        
        // Request user permission to update health data
        guard HKHealthStore.isHealthDataAvailable() else {
          print("Health data is not available!")
          return
        }
        
        healthStore.requestAuthorization(toShare: dataToShare, read: nil) {
            success, error in
            if (error != nil) {
                print("\(String(describing: error))")
            }
        }
    }
}

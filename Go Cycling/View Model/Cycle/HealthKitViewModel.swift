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
    
    // Called when the user turns on the health sync setting
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
    
    // Called as the user completes cycling distance
    func writeCyclingDistance(startDate: Date, distanceToAdd: Double) {
        let dataType = HKQuantityType.quantityType(forIdentifier: .distanceCycling)!
        
        let endDate = Date()
        
        let cyclingDistanceSample = HKQuantitySample(
            type: dataType,
            quantity: HKQuantity.init(unit: HKUnit.meter(), doubleValue: distanceToAdd),
            start: startDate,
            end: endDate
        )
        
        // Now, save the sample created above
        guard HKHealthStore.isHealthDataAvailable() else {
          print("Health data is not available!")
          return
        }
        
        healthStore.save(cyclingDistanceSample, withCompletion: {(success, error) -> Void in
            if (error != nil) {
                print("\(String(describing: error))")
            }
            
            if success {
                print("Cycling distance successfully saved in HealthKit")
                return
            }
        })
    }
}

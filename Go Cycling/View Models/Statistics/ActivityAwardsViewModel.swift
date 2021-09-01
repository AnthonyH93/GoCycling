//
//  ActivityAwardsViewModel.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-08-31.
//

import Foundation
import SwiftUI
import CoreData
import Combine

class ActivityAwardsViewModel: ObservableObject {
    
    private var initialRecords = Records.getStoredRecords()
    @Published var progressValues: [CGFloat] = [CGFloat].init(repeating: 0.0, count: 6)
    @Published var unlockedIcons = Records.getUnlockedIcons()
    
    @Published var records: Records? {
        willSet {
            print("Running")
            for index in 0..<awardValues.count {
                var progressFloat: CGFloat = 0.0
                // If icon is already unlocked then set progress to 100%
                if (unlockedIcons[index]) {
                    progressValues[index] = 1.0
                }
                // Single route awards
                if (index < 3) {
                    if let distance = self.records?.longestCyclingDistance {
                        progressFloat = CGFloat(distance/awardValues[index]) > 1.0 ? 1.0 : CGFloat(distance/awardValues[index])
                        progressValues[index] = progressFloat
                    }
                    // Use initial values if records have not updated yet
                    else if let distance = self.initialRecords?.longestCyclingDistance {
                        progressFloat = CGFloat(distance/awardValues[index]) > 1.0 ? 1.0 : CGFloat(distance/awardValues[index])
                        progressValues[index] = progressFloat
                    }
                }
                // Cummulative route awards
                else {
                    if let distance = self.records?.totalCyclingDistance {
                        progressFloat = CGFloat(distance/awardValues[index]) > 1.0 ? 1.0 : CGFloat(distance/awardValues[index])
                        progressValues[index] = progressFloat
                    }
                    // Use initial values if records have not updated yet
                    else if let distance = self.initialRecords?.totalCyclingDistance {
                        progressFloat = CGFloat(distance/awardValues[index]) > 1.0 ? 1.0 : CGFloat(distance/awardValues[index])
                        progressValues[index] = progressFloat
                    }
                }
            }
        }
    }
    
    // Distance are stored in m, must multiply by 1000 for km
    private var awardValues: [Double] = [10.0 * 1000, 25.0 * 1000, 50.0 * 1000, 100.0 * 1000, 250.0 * 1000, 500.0 * 1000]
    
    private var cancellable: AnyCancellable?
    
    init(recordsPublisher: AnyPublisher<[Records], Never> = RecordsStorage.shared.$storedRecords.eraseToAnyPublisher()) {
        cancellable = recordsPublisher.sink { records in
            print("Updating records")
            self.records = records[0]
        }
        
    }
}

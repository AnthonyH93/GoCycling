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
    @Published var progressStrings: [String] = [String].init(repeating: "0% Complete", count: 6)
    
    // Boolean to display alert for newly unlocked icon
    @Published var alertForNewIcon = false
    
    @Published var records: Records? {
        willSet {
            // Update published values when records change
            unlockedIcons = Records.getUnlockedIcons()
            for index in 0..<Records.awardValues.count {
                var progressFloat: CGFloat = 0.0
                // If icon is already unlocked then set progress to 100%
                if (unlockedIcons[index]) {
                    progressValues[index] = 1.0
                    // Check if user has been alerted of this unlocked icon
                    switch index {
                    case 0:
                        if (!UserDefaults.standard.bool(forKey: "alertedBronze1")) {
                            UserDefaults.standard.set(true, forKey: "alertedBronze1")
                            alertForNewIcon = true
                        }
                    case 1:
                        if (!UserDefaults.standard.bool(forKey: "alertedSilver1")) {
                            UserDefaults.standard.set(true, forKey: "alertedSilver1")
                            alertForNewIcon = true
                        }
                    case 2:
                        if (!UserDefaults.standard.bool(forKey: "alertedGold1")) {
                            UserDefaults.standard.set(true, forKey: "alertedGold1")
                            alertForNewIcon = true
                        }
                    case 3:
                        if (!UserDefaults.standard.bool(forKey: "alertedBronze2")) {
                            UserDefaults.standard.set(true, forKey: "alertedBronze2")
                            alertForNewIcon = true
                        }
                    case 4:
                        if (!UserDefaults.standard.bool(forKey: "alertedSilver2")) {
                            UserDefaults.standard.set(true, forKey: "alertedSilver2")
                            alertForNewIcon = true
                        }
                    case 5:
                        if (!UserDefaults.standard.bool(forKey: "alertedGold2")) {
                            UserDefaults.standard.set(true, forKey: "alertedGold2")
                            alertForNewIcon = true
                        }
                    default:
                        fatalError("Index out of range")
                    }
                }
                // Single route awards
                if (index < 3) {
                    if let distance = self.records?.longestCyclingDistance {
                        progressFloat = CGFloat(distance/Records.awardValues[index]) > 1.0 ? 1.0 : CGFloat(distance/Records.awardValues[index])
                        progressValues[index] = progressFloat
                    }
                    // Use initial values if records have not updated yet
                    else if let distance = self.initialRecords?.longestCyclingDistance {
                        progressFloat = CGFloat(distance/Records.awardValues[index]) > 1.0 ? 1.0 : CGFloat(distance/Records.awardValues[index])
                        progressValues[index] = progressFloat
                    }
                    let roundedProgress = round(progressFloat * 10000) / 100.0
                    progressStrings[index] = "\(roundedProgress)% Complete"
                }
                // Cummulative route awards
                else {
                    if let distance = self.records?.totalCyclingDistance {
                        progressFloat = CGFloat(distance/Records.awardValues[index]) > 1.0 ? 1.0 : CGFloat(distance/Records.awardValues[index])
                        progressValues[index] = progressFloat
                    }
                    // Use initial values if records have not updated yet
                    else if let distance = self.initialRecords?.totalCyclingDistance {
                        progressFloat = CGFloat(distance/Records.awardValues[index]) > 1.0 ? 1.0 : CGFloat(distance/Records.awardValues[index])
                        progressValues[index] = progressFloat
                    }
                    let roundedProgress = round(progressFloat * 10000) / 100.0
                    progressStrings[index] = "\(roundedProgress)% Complete"
                }
            }
        }
    }
    
    // Used by the activity awards view to display the correct medal for each award
    var medalOrder: [Medal] = [.bronze, .silver, .gold, .bronze, .silver, .gold]
    
    private var cancellable: AnyCancellable?
    
    init(recordsPublisher: AnyPublisher<[Records], Never> = RecordsStorage.shared.$storedRecords.eraseToAnyPublisher()) {
        cancellable = recordsPublisher.sink { records in
            print("Updating records")
            self.records = records[0]
        }
    }
    
    func getAwardName(index: Int, usingMetric: Bool) -> String {
        let distanceString = MetricsFormatting.formatDistance(distance: Records.awardValues[index], usingMetric: usingMetric)
        if (index < 3) {
            return "Cycle at least \(distanceString) in a single route"
        }
        else {
            return "Cycle a total of at least \(distanceString)"
        }
    }
    
    func resetAlert() {
        self.alertForNewIcon = false
    }
}

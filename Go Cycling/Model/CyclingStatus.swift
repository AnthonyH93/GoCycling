//
//  CyclingStatus.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-05-03.
//

import Foundation
import SwiftUI

class CyclingStatus: ObservableObject {
    @Published var isCycling = false
    
    func startedCycling() {
        isCycling = true
    }
    
    func stoppedCycling() {
        isCycling = false
    }
}

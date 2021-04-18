//
//  Units.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-18.
//

import Foundation

enum Units: String, CaseIterable, Identifiable {
    case metric
    case imperial

    var id: String { self.rawValue }
}

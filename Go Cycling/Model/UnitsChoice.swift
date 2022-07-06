//
//  UnitsChoice.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-25.
//

import Foundation

enum UnitsChoice: String, CaseIterable, Identifiable {
    case imperial
    case metric

    var id: String { self.rawValue }
}

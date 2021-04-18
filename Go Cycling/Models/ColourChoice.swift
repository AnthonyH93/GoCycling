//
//  Colours.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-18.
//

import Foundation
import SwiftUI

enum ColourChoice: String, CaseIterable, Identifiable {
    case red
    case orange
    case yellow
    case green
    case blue
    case indigo
    case violet

    var id: String { self.rawValue }
}

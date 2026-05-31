//
//  MapTypeChoice.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2026-05-31.
//

import Foundation
import MapKit

enum MapTypeChoice: String, CaseIterable {
    case standard = "Standard"
    case satellite = "Satellite"
    case hybrid = "Hybrid"

    var mkMapType: MKMapType {
        switch self {
        case .standard:  return .standard
        case .satellite: return .satellite
        case .hybrid:    return .hybrid
        }
    }
}

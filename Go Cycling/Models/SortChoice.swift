//
//  SortType.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-05-01.
//

import Foundation

enum SortChoice: String, CaseIterable, Identifiable {
    case distanceAscending
    case distanceDescending
    case dateAscending
    case dateDescending
    case timeAscending
    case timeDescending

    var id: String { self.rawValue }
}

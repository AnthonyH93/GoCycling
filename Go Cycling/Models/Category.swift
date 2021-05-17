//
//  Category.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-05-15.
//

import Foundation

class Category: Identifiable {
    var name: String
    var number: Int
    
    init(name: String, number: Int) {
        self.name = name
        self.number = number
    }
    
    var id: UUID { UUID() }
}

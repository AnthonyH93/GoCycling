//
//  TimerButton.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-03-14.
//

import SwiftUI

struct TimerButton: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let label: String
    let buttonColour: UIColor
    var isSmall: Bool = false

    var body: some View {
        Text(label)
            .foregroundColor(colorScheme == .dark ? .white : .black)
            .padding(.vertical, isSmall ? 6 : 20)
            .padding(.horizontal, isSmall ? 12 : 50)
            .background(Color(buttonColour))
            .cornerRadius(isSmall ? 8 : 10)
    }
}

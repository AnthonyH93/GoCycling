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
    
    let screenWidth = UIScreen.main.bounds.size.width
    
    var body: some View {
        Text(label)
            .foregroundColor(colorScheme == .dark ? .white : .black)
            .padding(.vertical, 20)
            .padding(.horizontal, 50)
            .background(Color(buttonColour))
            .cornerRadius(10)
    }
}

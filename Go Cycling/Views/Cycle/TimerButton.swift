//
//  TimerButton.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-03-14.
//

import SwiftUI

struct TimerButton: View {
    
    let label: String
    let buttonColour: UIColor
    
    var body: some View {
        Text(label)
            .foregroundColor(.white)
            .padding(.vertical, 20)
            .padding(.horizontal, 50)
            .background(Color(buttonColour))
            .cornerRadius(10)
    }
}

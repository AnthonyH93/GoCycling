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
    var isSecondary: Bool = false
    var systemImageName: String? = nil
    var expandsHorizontally: Bool = false

    var body: some View {
        HStack(spacing: isSmall ? 4 : 8) {
            if expandsHorizontally { Spacer(minLength: 0) }
            if let imageName = systemImageName {
                Image(systemName: imageName)
                    .font(.system(size: isSmall ? 11 : 17, weight: .bold))
            }
            Text(label)
                .font(.system(size: isSmall ? 13 : 17, weight: .bold))
                .minimumScaleFactor(0.8)
                .lineLimit(1)
            if expandsHorizontally { Spacer(minLength: 0) }
        }
        .foregroundColor(
            isSecondary
                ? Color(buttonColour)
                : (colorScheme == .dark ? .white : .black)
        )
        .padding(.vertical, isSmall ? 6 : 18)
        .padding(.horizontal, isSmall ? 12 : 24)
        .background(isSecondary ? Color.clear : Color(buttonColour))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(isSecondary ? Color(buttonColour) : Color.clear, lineWidth: 2)
        )
    }
}

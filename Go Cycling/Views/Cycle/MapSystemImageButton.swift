//
//  MapSystemImageButton.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-20.
//

import SwiftUI

struct MapSystemImageButton: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let systemImageString: String
    let buttonColour: UIColor
    
    var body: some View {
        Image(systemName: systemImageString)
            .foregroundColor(colorScheme == .dark ? .white : .black)
            .padding(.vertical, 20)
            .padding(.horizontal, 20)
            .background(Color(buttonColour))
            .cornerRadius(40)
    }
}

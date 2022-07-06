//
//  SingleAwardView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-08-31.
//

import SwiftUI

struct SingleActivityAwardView: View {
    let progress: CGFloat
    let iconName: String
    let progressString: String
    let medal: Medal
    
    let gold = "🥇".image()
    let silver = "🥈".image()
    let bronze = "🥉".image()
    
    var body: some View {
        VStack {
            HStack {
                Text(iconName)
                Spacer()
            }
            HStack {
                Text(progressString)
                Spacer()
                // Decide which emoji image to display
                switch medal {
                case .gold:
                    if let image = gold {
                        Image(uiImage: image)
                    }
                case .silver:
                    if let image = silver {
                        Image(uiImage: image)
                    }
                case .bronze:
                    if let image = bronze {
                        Image(uiImage: image)
                    }
                }
            }
            .padding()
            .overlay(LockedIconCoverView(progress: progress))
        }
    }
}

struct SingleAwardView_Previews: PreviewProvider {
    static var previews: some View {
        SingleActivityAwardView(progress: 0.5, iconName: "Icon Name", progressString: "Progress", medal: Medal.gold)
    }
}

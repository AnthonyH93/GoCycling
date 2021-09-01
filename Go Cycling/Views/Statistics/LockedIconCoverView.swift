//
//  LockedIconCoverView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-08-31.
//

import SwiftUI

struct LockedIconCoverView: View {
    let progress: CGFloat
    // State variable used for animation
    @State var showingProgress = false
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var preferences: PreferencesStorage
    
    var body: some View {
        // Creates a progress bar which will show the percentage progress towards unlocking the icon
        VStack {
            HorizontalBar(ratio: showingProgress ? progress : 0).animation(Animation.easeIn(duration: 1))
                .foregroundColor(Color(UserPreferences.convertColourChoiceToUIColor(colour: preferences.storedPreferences[0].colourChoiceConverted)))
                .opacity(0.5)
                .onAppear {
                    showingProgress = true
                }
                .onDisappear {
                    showingProgress = false
                }
        }
        .border(colorScheme == .dark ? Color.white : Color.black, width: 3)
    }
    
    // Horizontal bar to animate the current progress
    struct HorizontalBar: Shape {
        var ratio: CGFloat

        var animatableData: CGFloat {
            get { return ratio }
            set { ratio = newValue }
        }

        func path(in rect: CGRect) -> Path {
            var p = Path()

            p.move(to: CGPoint.zero)

            let width = rect.size.width * ratio
            p.addLine(to: CGPoint(x: width, y: 0))

            let height = rect.size.height

            p.addLine(to: CGPoint(x: width, y: height))

            p.addLine(to: CGPoint(x: 0, y: height))

            p.closeSubpath()

            return p
        }
    }
}

struct LockedIconCoverView_Previews: PreviewProvider {
    static var previews: some View {
        LockedIconCoverView(progress: 0.5)
    }
}

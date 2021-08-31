//
//  LockedIconCoverView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-08-31.
//

import SwiftUI

struct LockedIconCoverView: View {
    // State variable used for animation
    @State var showingProgress = false
    
    var body: some View {
        // Creates a progress bar which will show the percentage progress towards unlocking the icon
        VStack {
            HorizontalBar(ratio: showingProgress ? 0.7 : 0).animation(Animation.easeIn(duration: 1))
                .foregroundColor(.green)
                .opacity(0.4)
                .onAppear {
                    showingProgress = true
                }
                .onDisappear {
                    showingProgress = false
                }
        }
        .background(Rectangle().foregroundColor(.black).opacity(0.4))
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
        LockedIconCoverView()
    }
}

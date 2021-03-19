//
//  ContentView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-03-14.
//

import SwiftUI

struct CycleView: View {
    
    @ObservedObject var stopWatchViewModel = StopWatchViewModel()
    
    var body: some View {
        VStack {
            Spacer()
            Text(stopWatchViewModel.timeElapsedFormatted)
                .font(.custom("Avenir", size: 40))
            (!self.stopWatchViewModel.isTiming) ?
            Button (action: {self.stopWatchViewModel.start()}) {
                TimerButton(label: "Start", buttonColor: .green)
                    .padding(.bottom, 20)
                } :
            Button (action: {self.stopWatchViewModel.stop()}) {
                TimerButton(label: "Stop", buttonColor: .red)
                    .padding(.bottom, 20)
            }
        }
    }
}

struct CycleView_Previews: PreviewProvider {
    static var previews: some View {
        CycleView()
    }
}

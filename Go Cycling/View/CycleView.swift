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
            HStack {
                if (self.stopWatchViewModel.mode == .timing) {
                    Button (action: {self.stopWatchViewModel.pause()}) {
                        TimerButton(label: "Pause", buttonColor: .yellow)
                            .padding(.bottom, 20)
                    }
                    Button (action: {self.stopWatchViewModel.stop()}) {
                        TimerButton(label: "Stop", buttonColor: .red)
                            .padding(.bottom, 20)
                    }
                }
                if (self.stopWatchViewModel.mode == .stopped) {
                    Button (action: {self.stopWatchViewModel.start()}) {
                        TimerButton(label: "Start", buttonColor: .green)
                            .padding(.bottom, 20)
                    }
                }
                if (self.stopWatchViewModel.mode == .paused) {
                    Button (action: {self.stopWatchViewModel.start()}) {
                        TimerButton(label: "Resume", buttonColor: .green)
                            .padding(.bottom, 20)
                    }
                    Button (action: {self.stopWatchViewModel.stop()}) {
                        TimerButton(label: "Stop", buttonColor: .red)
                            .padding(.bottom, 20)
                    }
                }
            }
        }
    }
}

struct CycleView_Previews: PreviewProvider {
    static var previews: some View {
        CycleView()
    }
}

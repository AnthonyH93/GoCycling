//
//  ContentView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-03-14.
//

import SwiftUI

struct CycleView: View {
    
    @ObservedObject var stopWatchViewModel = StopWatchViewModel()
    @State private var showingAlert = false
    
    var body: some View {
        VStack {
            MapView()
            Spacer()
            Text(stopWatchViewModel.timeElapsedFormatted)
                .font(.custom("Avenir", size: 40))
            HStack {
                if (self.stopWatchViewModel.mode == .timing) {
                    Button (action: {self.stopWatchViewModel.pause()}) {
                        TimerButton(label: "Pause", buttonColor: .yellow)
                            .padding(.bottom, 20)
                    }
                    Button (action: {self.confirmStop()}) {
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
                    Button (action: {self.confirmStop()}) {
                        TimerButton(label: "Stop", buttonColor: .red)
                            .padding(.bottom, 20)
                    }
                }
            }
        }
        
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Are you sure that you want to end the current bike ride?"),
                  message: Text("Please confirm that you are ready to end the current bike ride."),
                  primaryButton: .destructive(Text("Stop")) {
                    self.stopWatchViewModel.stop()
                  },
                  secondaryButton: .cancel()
            )
        }
    }
    
    func confirmStop() {
        self.stopWatchViewModel.pause()
        showingAlert = true
    }
}

struct CycleView_Previews: PreviewProvider {
    static var previews: some View {
        CycleView()
    }
}

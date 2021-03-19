//
//  StopWatchController.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-03-14.
//

import Foundation

class StopWatchViewModel: ObservableObject {
    
    @Published var timeElapsedFormatted = "00:00.00"
    @Published var mode: stopWatchMode = .stopped
    
    var secondsElapsed = 0.0
    var completedSecondsElapsed = 0.0
    var timer = Timer()
    
    func start() {
        self.mode = .timing
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
        self.secondsElapsed += 0.01
        self.formatTime()
        }
    }
    
    func stop() {
        timer.invalidate()
        self.mode = .stopped
        self.completedSecondsElapsed = self.secondsElapsed
        self.secondsElapsed = 0.0
        self.timeElapsedFormatted = "00:00.00"
    }
    
    func pause() {
        timer.invalidate()
        self.mode = .paused
    }
    
    func formatTime() {
        let minutes: Int32 = Int32(self.secondsElapsed/60)
        let minutesString = (minutes < 10) ? "0\(minutes)" : "\(minutes)"
        let seconds: Int32 = Int32(self.secondsElapsed) - (minutes * 60)
        let secondsString = (seconds < 10) ? "0\(seconds)" : "\(seconds)"
        let milliseconds: Int32 = Int32(self.secondsElapsed.truncatingRemainder(dividingBy: 1) * 100)
        let millisecondsString = (milliseconds < 10) ? "0\(milliseconds)" : "\(milliseconds)"
        self.timeElapsedFormatted = minutesString + ":" + secondsString + "." + millisecondsString
    }
}

enum stopWatchMode {
    case timing
    case stopped
    case paused
}

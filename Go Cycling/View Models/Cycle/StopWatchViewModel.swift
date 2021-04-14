//
//  StopWatchController.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-03-14.
//

import Foundation

class StopWatchViewModel: ObservableObject {
    
    @Published var timeElapsedFormatted = "0:00:00"
    @Published var mode: stopWatchMode = .stopped
    
    var secondsElapsed = 0.0
    var completedSecondsElapsed = 0.0
    var timer = Timer()
    
    func start() {
        self.mode = .timing
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
        self.secondsElapsed += 1
        self.formatTime()
        }
    }
    
    func stop() {
        timer.invalidate()
        self.mode = .stopped
        self.completedSecondsElapsed = self.secondsElapsed
        self.secondsElapsed = 0.0
        self.timeElapsedFormatted = "0:00:00"
    }
    
    func pause() {
        timer.invalidate()
        self.mode = .paused
    }
    
    func formatTime() {
        var hours: Int32 = 0
        var hoursString = "0"
        var minutes: Int32 = Int32(self.secondsElapsed/60)
        if (minutes > 59) {
            hours = minutes/60
            hoursString = "\(hours)"
            minutes = minutes - (hours * 60)
        }
        let minutesString = (minutes < 10) ? "0\(minutes)" : "\(minutes)"
        let seconds: Int32 = Int32(self.secondsElapsed) - (minutes * 60)
        let secondsString = (seconds < 10) ? "0\(seconds)" : "\(seconds)"
        self.timeElapsedFormatted = hoursString + ":" + minutesString + ":" + secondsString
    }
}

enum stopWatchMode {
    case timing
    case stopped
    case paused
}

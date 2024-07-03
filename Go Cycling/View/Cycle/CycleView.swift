//
//  ContentView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-03-14.
//

import SwiftUI

struct CycleView: View {
    
    @EnvironmentObject var cyclingStatus: CyclingStatus
    
    @StateObject var timer = TimerViewModel()
    @State private var showingAlert = false
    @State private var cyclingSpeed = 0.0
    @State private var cyclingStartTime = Date()
    @State private var timeCycling = 0.0
    @State private var showingRouteNamingPopover = false
    
    @StateObject var locationManager = LocationViewModel.locationManager
    
    @StateObject var healthKitManager = HealthKitManager.healthKitManager
    
    @EnvironmentObject var preferences: Preferences
    
    var body: some View {
        GeometryReader { (geometry) in
            VStack {
                MapWithSpeedView(cyclingStartTime: $cyclingStartTime, timeCycling: $timeCycling, screenWidth: geometry.size.width)
                // Alert about visiting settings if location access is not allowed
                .alert(isPresented: $locationManager.showLocationSettingsAlert) {
                    Alert(title: Text("Location settings may not be correct"),
                          message: Text(locationManager.locationSettingsAlertMessage),
                          primaryButton: .default(Text("Open Settings")) {
                            // Pause the current cycling session
                            self.timer.pause()
                            // Open Settings app
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                          },
                          secondaryButton: .cancel(Text("Ignore"))
                    )
                }
                Text(formatTimeString(accumulatedTime: timer.totalAccumulatedTime))
                    .font(.custom("Avenir", size: 40))
                Spacer()
                HStack {
                    if (timer.isRunning) {
                        Button (action: {self.timer.pause()}) {
                            TimerButton(label: "Pause", buttonColour: UIColor.systemYellow)
                                .padding(.bottom, 20)
                                .minimumScaleFactor(0.3)
                                .lineLimit(1)
                        }
                        Button (action: {self.confirmStop()}) {
                            TimerButton(label: "Stop", buttonColour: UIColor.systemRed)
                                .padding(.bottom, 20)
                                .minimumScaleFactor(0.3)
                                .lineLimit(1)
                        }
                    }
                    if (timer.isStopped) {
                        Button (action: {self.startCycling()}) {
                            TimerButton(label: "Start", buttonColour: UIColor.systemGreen)
                                .padding(.bottom, 20)
                                .minimumScaleFactor(0.3)
                                .lineLimit(1)
                        }
                    }
                    if (timer.isPaused) {
                        Button (action: {self.timer.start()}) {
                            TimerButton(label: "Resume", buttonColour: UIColor.systemGreen)
                                .padding(.bottom, 20)
                                .minimumScaleFactor(0.3)
                                .lineLimit(1)
                        }
                        Button (action: {self.confirmStop()}) {
                            TimerButton(label: "Stop", buttonColour: UIColor.systemRed)
                                .padding(.bottom, 20)
                                .minimumScaleFactor(0.3)
                                .lineLimit(1)
                        }
                    }
                }
                // Confirmation alert about ending the current route
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Are you sure that you want to end the current route?"),
                          message: Text("Please confirm that you are ready to end the current route."),
                          primaryButton: .destructive(Text("Stop")) {
                            self.timeCycling = timer.totalAccumulatedTime
                            self.timer.stop()
                            cyclingStatus.stoppedCycling()
                            
                            // Present route naming popover if necessary
                            if (preferences.namedRoutes) {
                                self.showingRouteNamingPopover = true
                            }
                          },
                          secondaryButton: .cancel()
                    )
                }
                Spacer()
            }
            .sheet(isPresented: $showingRouteNamingPopover) {
                RouteNameModalView(showEditModal: $showingRouteNamingPopover, bikeRideToEdit: nil)
            }
        }
    }
    
    func formatTimeString(accumulatedTime: TimeInterval) -> String {
        let hours = Int(accumulatedTime) / 3600
        let minutes = Int(accumulatedTime) / 60 % 60
        let seconds = Int(accumulatedTime) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    func startCycling() {
        // Send an alert about location settings if it is necessary
        locationManager.setLocationAlertStatus()
        cyclingStatus.startedCycling()
        self.cyclingStartTime = Date()
        self.timeCycling = 0.0
        self.timer.start()
    }
    
    func confirmStop() {
        // Completing a route is a review worthy event
        ReviewManager.incrementReviewWorthyCount()
        // Keep track of whether user has completed a route
        ReviewManager.completedRoute()
        self.timer.pause()
        showingAlert = true
    }
}

struct CycleView_Previews: PreviewProvider {
    static var previews: some View {
        CycleView()
    }
}

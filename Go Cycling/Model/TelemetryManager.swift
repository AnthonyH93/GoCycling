//
//  TelemetryManager.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2025-04-01.
//

import Foundation
import TelemetryDeck

// Utility class for sending signals to TelemetryDeck
class TelemetryManager {
    
    // Singleton instance of this class
    static let sharedTelemetryManager = TelemetryManager()
    
    // Toggle for collecting telemetry data
    private static var telemetryOn: Bool?
    
    // Structure for initializing the TelemetryManager
    struct TelemetryManagerConfig {
        let appID: String
    }
    
    private static var config: TelemetryManagerConfig?
    
    class func setup(_ config: TelemetryManagerConfig) {
        TelemetryManager.config = config
    }
    
    private init(){
        // Choose mode based on whether configuration is complete
        if let config = TelemetryManager.config {
            let telemetryDeckConfig = TelemetryDeck.Config(appID: config.appID)
            telemetryDeckConfig.defaultSignalPrefix = "GoCycling"
            TelemetryDeck.initialize(config: telemetryDeckConfig)
            TelemetryManager.telemetryOn = true
        }
        else {
            TelemetryManager.telemetryOn = false
        }
    }
    
    func sendCyclingSignal(tab: TelemetryTab, action: TelemetryCyclingAction) {
        if TelemetryManager.telemetryOn ?? false {
            TelemetryDeck.signal(".\(tab).\(action)")
        }
    }

    func sendSettingsSignal(section: TelemetrySettingsSection, action: TelemetrySettingsAction, parameters: [String : String]? = nil) {
        if TelemetryManager.telemetryOn ?? false {
            if let params = parameters {
                TelemetryDeck.signal(
                    ".\(TelemetryTab.Settings).\(section).\(action)",
                    parameters: params
                )
            }
            else {
                TelemetryDeck.signal(".\(TelemetryTab.Settings).\(section).\(action)")
            }
        }
    }
}

// Enums to control types of signals
enum TelemetryTab: String {
    case Cycle = "Cycle"
    case History = "History"
    case Statistics = "Statistics"
    case Settings = "Settings"
}

enum TelemetryCyclingAction: String {
    // Cycling actions
    case Start = "startPressed"
    case Stop = "stopPressed"
    case Pause = "pausePressed"
    case Resume = "resumePressed"
    // Route actions
    case Save = "savedRouteWithoutCategory"
    case NewSave = "savedRouteWithNewCategory"
    case ExistingSave = "savedRouteWithExistingCategory"
    // History actions
    case Filter = "historyFilterApplied"
    case Sort = "sortOrderApplied"
    case Click = "clickedOnRoute"
    case EditCategory = "editedCategoryName"
    case EditRoute = "editedRouteName"
    case Delete = "deletedRoute"
    // Statistics actions
    case OneWeek = "clickedOn1Week"
    case FiveWeeks = "clickedOn5Weeks"
    case ThirtyWeeks = "clickedOn30Weeks"
    case AwardUnlocked = "unlockedActivityAward"
}

enum TelemetrySettingsSection: String {
    case Customization = "Customization"
    case Metrics = "CyclingMetrics"
    case History = "CyclingHistory"
    case Cycling = "Cycling"
    case Sync = "Sync"
    case Reset = "Reset"
}

enum TelemetrySettingsAction: String {
    // Customization actions
    case Colour = "colourChanged"
    case AppIcon = "appIconChanged"
    // Metrics actions
    case Units = "preferredUnitsChanged"
    case MetricsOnMap = "metricsOnMapSwitchPressed"
    case LargeMetrics = "largeMetricsSwitchPressed"
    // History actions
    case RoutesEnabled = "routeCategorizationEnabledSwitchPressed"
    case DeletionEnabled = "deletionEnabledSwitchPressed"
    case DeletionConfirmtion = "deletionConfirmationSwitchPressed"
    // Cycling actions
    case AutoLock = "disableAutoLockSwitchPressed"
    case ClearHistory = "clearLocalHistory"
    // Sync actions
    case iCloud = "iCloudSwitchPressed"
    case Health = "healthSwitchPressed"
    // Reset actions
    case Defaults = "resetToDefaultSettingsPressed"
    case DeleteRoutes = "deleteAllRoutesPressed"
    case DeleteStats = "deleteAllStatisticsPressed"
}

//
//  ReviewManager.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2022-07-06.
//

import Foundation
import StoreKit

// Class to manage interactions with Go Cycling reviewing
class ReviewManager {
    
    static let minimumReviewWorthyActionCount = 2
    
    static let reviewCountKey = "ReviewWorthyActionCount"
    static let reviewRequestVersionKey = "LastVersionReviewRequested"
    static let completedRouteKey = "CompletedOneRoute"
    
    static let productURLString = "https://apps.apple.com/app/id1565861313"

    static func incrementReviewWorthyCount() {
        let defaults = UserDefaults.standard

        var actionCount = defaults.integer(forKey: reviewCountKey)
        
        // Limit for requesting a review is 2, so no need to count past 3
        if actionCount < 3 {
            actionCount += 1
            defaults.set(actionCount, forKey: reviewCountKey)
        }
    }
    
    static func completedRoute() {
        let defaults = UserDefaults.standard
        
        let completedRoute = defaults.bool(forKey: completedRouteKey)
        
        if !completedRoute {
            defaults.set(true, forKey: completedRouteKey)
        }
    }
    
    static func requestReviewIfAppropriate() {
        let defaults = UserDefaults.standard
        let bundle = Bundle.main

        // Must have completed a route
        let completedRoute = defaults.bool(forKey: completedRouteKey)
        
        guard completedRoute else {
            return
        }
        
        let actionCount = defaults.integer(forKey: reviewCountKey)

        guard actionCount >= minimumReviewWorthyActionCount else {
            return
        }

        let bundleVersionKey = kCFBundleVersionKey as String
        let currentVersion = bundle.object(forInfoDictionaryKey: bundleVersionKey) as? String
        let lastVersion = defaults.string(forKey: reviewRequestVersionKey)

        guard lastVersion == nil || lastVersion != currentVersion else {
            return
        }

        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }

        defaults.set(0, forKey: reviewCountKey)
        defaults.set(currentVersion, forKey: reviewRequestVersionKey)
    }
    
    static func getProductURL() -> URL {
        return NSURL(string: productURLString)! as URL
    }
    
    static func getWriteReviewURL() -> URL? {
        let productURL = getProductURL()
        
        var components = URLComponents(url: productURL, resolvingAgainstBaseURL: false)

        components?.queryItems = [
          URLQueryItem(name: "action", value: "write-review")
        ]

        guard let writeReviewURL = components?.url else {
          return nil
        }
        
        return writeReviewURL
    }
}

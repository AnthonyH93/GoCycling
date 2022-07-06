//
//  UIApplicationExtension.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2022-07-06.
//  Found at https://stackoverflow.com/questions/63953891/requestreview-was-deprecated-in-ios-14-0

import SwiftUI

extension UIApplication {
    var currentScene: UIWindowScene? {
        connectedScenes
            .first { $0.activationState == .foregroundActive } as? UIWindowScene
    }
}

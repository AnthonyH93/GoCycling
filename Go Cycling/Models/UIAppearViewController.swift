//
//  UIAppearViewController.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-05-06.
//
//  Found at: https://developer.apple.com/forums/thread/655338 to combat double .onAppear() call bug

import Foundation
import UIKit
import SwiftUI

struct UIKitAppear: UIViewControllerRepresentable {
    let action: () -> Void
    func makeUIViewController(context: Context) -> UIAppearViewController {
       let vc = UIAppearViewController()
        vc.action = action
        return vc
    }
    func updateUIViewController(_ controller: UIAppearViewController, context: Context) {
        controller.action = action
    }
}
class UIAppearViewController: UIViewController {
    var action: () -> Void = {}
    override func viewDidLoad() {
        view.addSubview(UILabel())
    }
    override func viewDidAppear(_ animated: Bool) {
        action()
    }
}
public extension View {
    func uiKitOnAppear(_ perform: @escaping () -> Void) -> some View {
        self.background(UIKitAppear(action: perform))
    }
}

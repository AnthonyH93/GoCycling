//
//  AnchorButton.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-05-07.
//

import Foundation
import SwiftUI

struct AnchorButton<Content: View>: View {
    typealias Action = (_ sender: AnyObject?) -> Void
    let callback: Action
    var content: Content
    @StateObject private var viewWrapper = ViewWrapper(view: UIView(frame: .zero))

    init(action: @escaping Action, @ViewBuilder label: () -> Content) {
        self.callback = action
        self.content = label()
    }

    var body: some View {
        return
            ZStack {
                InternalAnchorView(view: viewWrapper.view)
                Button {
                    self.callback(BarButtonWatcher.lastBarButtonItem ?? viewWrapper.view)
                } label: {
                    content
                }
            }.onAppear {
                // Lazy global needs access to init
                _ = BarButtonWatcher.shared
            }
    }

    private struct InternalAnchorView: UIViewRepresentable {
        var view: UIView
        func makeUIView(context: Self.Context) -> UIView { view }
        func updateUIView(_ uiView: UIView, context: Self.Context) {}
    }

    // View can't be directly stored as StateObject (not an observable object)
    private class ViewWrapper: ObservableObject {
        @Published var view: UIView

        init(view: UIView) {
            self.view = view
        }
    }
}

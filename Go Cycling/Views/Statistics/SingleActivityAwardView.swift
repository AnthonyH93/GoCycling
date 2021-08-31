//
//  SingleAwardView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-08-31.
//

import SwiftUI

struct SingleActivityAwardView: View {
    var body: some View {
        VStack {
            HStack {
                Text("Icon Name")
                Spacer()
            }
            HStack {
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                Spacer()
                Text("Text 2")
            }
            .padding()
            .overlay(LockedIconCoverView())
        }
    }
}

struct SingleAwardView_Previews: PreviewProvider {
    static var previews: some View {
        SingleActivityAwardView()
    }
}

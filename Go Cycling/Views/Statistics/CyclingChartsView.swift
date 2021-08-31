//
//  CyclingChartsView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-08-31.
//

import SwiftUI

struct CyclingChartsView: View {
    var body: some View {
        Section (header: Text(RecordsFormatting.headerStrings[1]), footer: Text(RecordsFormatting.footerStrings[0])) {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }
    }
}

struct CyclingChartsView_Previews: PreviewProvider {
    static var previews: some View {
        CyclingChartsView()
    }
}

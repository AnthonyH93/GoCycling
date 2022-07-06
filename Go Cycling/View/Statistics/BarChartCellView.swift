//
//  BarChartCellView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-09-02.
//

import SwiftUI

struct BarChartCellView: View {
    var value: Double
    var barColor: Color
                         
    var body: some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(barColor)
            .scaleEffect(CGSize(width: 1, height: value), anchor: .bottom)
                
    }  
}

struct BarChartCellView_Previews: PreviewProvider {
    static var previews: some View {
        BarChartCellView(value: 0.5, barColor: .orange)
    }
}

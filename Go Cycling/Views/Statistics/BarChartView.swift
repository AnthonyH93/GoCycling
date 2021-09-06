//
//  BarChartView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-09-02.
//

import SwiftUI

struct BarChartView: View {
    var index: Int
    
    @StateObject var chartViewModel = CyclingChartsViewModel()
    
    @EnvironmentObject var preferences: PreferencesStorage
    @Environment(\.colorScheme) var colorScheme
    
    @State private var selectedValue = ""
    @State private var touchLocation: CGFloat = -1
    @State private var currentOpacity: Double = 1.0
    
    var body: some View {
        VStack (alignment: .leading) {
            if (selectedValue == "") {
                
            }
            else {
                Text("Selected Value: \(selectedValue)")
                    .bold()
            }
            // Chart
            GeometryReader { geometry in
                VStack {
                    HStack {
                        ForEach (0..<chartViewModel.pastData[index].count, id: \.self) { id in
                            BarChartCellView(value: chartViewModel.pastDataNormalized[index][id], barColor: Color(UserPreferences.convertColourChoiceToUIColor(colour: preferences.storedPreferences[0].colourChoiceConverted)))
                                .opacity(barIsTouched(id: id) ? 1 : currentOpacity)
                                .scaleEffect(barIsTouched(id: id) ? CGSize(width: 1.05, height: 1) : CGSize(width: 1, height: 1), anchor: .bottom)
                                .animation(.spring())
                                .padding(.top)
                        }
                    }
                    .gesture(DragGesture(minimumDistance: 0)
                        .onChanged({ position in
                            let touchPosition = position.location.x/geometry.frame(in: .local).width
                                                    
                            touchLocation = touchPosition
                            currentOpacity = 0.7
                            updateCurrentValue()
                        })
                        .onEnded({ position in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                resetValues()
                            }
                        })
                    )
                    Text(chartViewModel.getDateRange(index: index))
                        .bold()
                        .padding(5)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .background(RoundedRectangle(cornerRadius: 5).foregroundColor(colorScheme == .dark ? .black : .white).shadow(color: colorScheme == .dark ? .white : .black, radius: 3))
                }
            }
        }
        .padding()
        .navigationBarTitle(CyclingChartsViewModel.titleStrings[index], displayMode: .inline)
    }
    
    func barIsTouched(id: Int) -> Bool {
        touchLocation > CGFloat(id)/CGFloat(chartViewModel.pastData[index].count) && touchLocation < CGFloat(id+1)/CGFloat(chartViewModel.pastData[index].count)
    }
    
    func updateCurrentValue()    {
        let id = Int(touchLocation * CGFloat(chartViewModel.pastData[index].count))
        guard index < chartViewModel.pastData[index].count && index >= 0 else {
            selectedValue = ""
            return
        }
        selectedValue = "\(chartViewModel.pastData[index][id])"
        //currentLabel = data[index].label
    }
    
    func resetValues() {
        touchLocation = -1
        selectedValue = ""
        currentOpacity = 1
    }
}

//struct BarChartView_Previews: PreviewProvider {
//    static var previews: some View {
//        BarChartView()
//    }
//}

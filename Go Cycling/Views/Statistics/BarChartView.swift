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
    @State private var selectedDateValue = ""
    @State private var touchLocation: CGFloat = -1
    @State private var currentOpacity: Double = 1.0
    
    @State private var barChartUnitsSelection = BarChartUnits.distance
    
    var body: some View {
        VStack (alignment: .leading) {
            Picker("Bar Chart Units", selection: $barChartUnitsSelection) {
                Text("Distance").tag(BarChartUnits.distance)
                Text("Time").tag(BarChartUnits.time)
                Text("Routes").tag(BarChartUnits.numberOfRoutes)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.bottom, 10)
            
            if (selectedValue != "") {
                Text("\(index == 0 ? "Date Selected:" : "Date Range Selected:") \(selectedDateValue)")
                    .bold()
                    .padding(.bottom, 10)
                switch (barChartUnitsSelection) {
                case .distance:
                    Text("Distance Cycled: \(selectedValue)")
                        .bold()
                case .time:
                    Text("Time Cycled: \(selectedValue)")
                        .bold()
                case .numberOfRoutes:
                    Text("Number of Completed Routes: \(selectedValue)")
                        .bold()
                }
            }
            // Chart
            GeometryReader { geometry in
                VStack {
                    HStack {
                        ForEach (0..<chartViewModel.pastData[index + (barChartUnitsSelection.id * 3)].count, id: \.self) { id in
                            BarChartCellView(value: chartViewModel.pastDataNormalized[index + (barChartUnitsSelection.id * 3)][id], barColor: Color(UserPreferences.convertColourChoiceToUIColor(colour: preferences.storedPreferences[0].colourChoiceConverted)))
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
                            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
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
        .onChange(of: barChartUnitsSelection, perform: { _ in
            resetValues()
        })
    }
    
    func barIsTouched(id: Int) -> Bool {
        touchLocation > CGFloat(id)/CGFloat(chartViewModel.pastData[index + ((index < 1 ? 1 : barChartUnitsSelection.id) * 3)].count) && touchLocation < CGFloat(id+1)/CGFloat(chartViewModel.pastData[index + ((index < 1 ? 1 : barChartUnitsSelection.id) * 3)].count)
    }
    
    func updateCurrentValue()    {
        let id = Int(touchLocation * CGFloat(chartViewModel.pastData[index + (barChartUnitsSelection.id * 3)].count))
        guard id < chartViewModel.pastData[index + ((index < 1 ? 1 : barChartUnitsSelection.id) * 3)].count && id >= 0 else {
            selectedValue = ""
            selectedDateValue = ""
            return
        }
        switch (barChartUnitsSelection) {
        case .distance:
            selectedValue = "\(MetricsFormatting.formatDistance(distance: chartViewModel.pastData[index + (barChartUnitsSelection.id * 3)][id], usingMetric: preferences.storedPreferences[0].usingMetric))"
        case .time:
            selectedValue = "\(MetricsFormatting.formatTime(time: chartViewModel.pastData[index + (barChartUnitsSelection.id * 3)][id]))"
        case .numberOfRoutes:
            selectedValue = "\(Int(chartViewModel.pastData[index + (barChartUnitsSelection.id * 3)][id]))"
        }
        selectedDateValue = chartViewModel.getIndividualDateRange(index: index, entryIndex: id)
    }
    
    func resetValues() {
        touchLocation = -1
        selectedValue = ""
        selectedDateValue = ""
        currentOpacity = 1
    }
}

// Used for the picker
enum BarChartUnits: Int, CaseIterable, Identifiable {
    case distance = 0
    case time
    case numberOfRoutes

    var id: Int { self.rawValue }
}

//struct BarChartView_Previews: PreviewProvider {
//    static var previews: some View {
//        BarChartView()
//    }
//}

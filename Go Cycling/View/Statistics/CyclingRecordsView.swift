//
//  CyclingRecordsView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-08-30.
//

import SwiftUI

struct CyclingRecordsView: View {
    @EnvironmentObject var preferences: Preferences
    @EnvironmentObject var records: CyclingRecords
    
    var body: some View {
        Section(header: Text(RecordsFormatting.headerStrings[0]), footer: Text(RecordsFormatting.getCyclingRecordsFooterText(usingMetric: preferences.usingMetric))) {
            VStack {
                HStack {
                    Text("Single Route Records")
                        .font(.headline)
                        .foregroundColor(Color(UserPreferences.convertColourChoiceToUIColor(colour: preferences.colourChoiceConverted)))
                    Spacer()
                }
                CyclingSingleRecordView(recordValue: MetricsFormatting.formatDistance(distance: records.longestCyclingDistance, usingMetric: preferences.usingMetric), recordName: RecordsFormatting.recordsStrings[3], recordDate: RecordsFormatting.formatOptionalDate(date: records.longestCyclingDistanceDate), firstEntry: true)
                CyclingSingleRecordView(recordValue: MetricsFormatting.formatTime(time: records.longestCyclingTime), recordName: RecordsFormatting.recordsStrings[4], recordDate: RecordsFormatting.formatOptionalDate(date: records.longestCyclingTimeDate), firstEntry: false)
                CyclingSingleRecordView(recordValue: MetricsFormatting.formatSingleSpeed(speed: records.fastestAverageSpeed, usingMetric: preferences.usingMetric), recordName: RecordsFormatting.recordsStrings[5], recordDate: RecordsFormatting.formatOptionalDate(date: records.fastestAverageSpeedDate), firstEntry: false)
            }
            VStack {
                HStack {
                    Text("Cummulative Records")
                        .font(.headline)
                        .foregroundColor(Color(UserPreferences.convertColourChoiceToUIColor(colour: preferences.colourChoiceConverted)))
                    Spacer()
                }
                CyclingSingleRecordView(recordValue: MetricsFormatting.formatDistance(distance: records.totalCyclingDistance, usingMetric: preferences.usingMetric), recordName: RecordsFormatting.recordsStrings[0], recordDate: nil, firstEntry: true)
                CyclingSingleRecordView(recordValue: MetricsFormatting.formatTime(time: records.totalCyclingTime), recordName: RecordsFormatting.recordsStrings[1], recordDate: nil, firstEntry: false)
                CyclingSingleRecordView(recordValue: "\(records.totalCyclingRoutes)", recordName: RecordsFormatting.recordsStrings[2], recordDate: nil, firstEntry: false)
            }
        }
    }
}

struct CyclingRecordsView_Previews: PreviewProvider {
    static var previews: some View {
        CyclingRecordsView()
    }
}

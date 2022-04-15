//
//  CyclingRecordsView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-08-30.
//

import SwiftUI

struct CyclingRecordsView: View {
    @EnvironmentObject var preferences: Preferences
    @EnvironmentObject var records: RecordsStorage
    
    var body: some View {
        Section(header: Text(RecordsFormatting.headerStrings[0]), footer: Text(RecordsFormatting.getCyclingRecordsFooterText(usingMetric: preferences.usingMetric))) {
            VStack {
                HStack {
                    Text("Single Route Records")
                        .font(.headline)
                        .foregroundColor(Color(UserPreferences.convertColourChoiceToUIColor(colour: preferences.colourChoiceConverted)))
                    Spacer()
                }
                CyclingSingleRecordView(recordValue: MetricsFormatting.formatDistance(distance: records.storedRecords[0].longestCyclingDistance, usingMetric: preferences.usingMetric), recordName: RecordsFormatting.recordsStrings[3], recordDate: RecordsFormatting.formatOptionalDate(date: records.storedRecords[0].longestCyclingDistanceDate), firstEntry: true)
                CyclingSingleRecordView(recordValue: MetricsFormatting.formatTime(time: records.storedRecords[0].longestCyclingTime), recordName: RecordsFormatting.recordsStrings[4], recordDate: RecordsFormatting.formatOptionalDate(date: records.storedRecords[0].longestCyclingTimeDate), firstEntry: false)
                CyclingSingleRecordView(recordValue: MetricsFormatting.formatSingleSpeed(speed: records.storedRecords[0].fastestAverageSpeed, usingMetric: preferences.usingMetric), recordName: RecordsFormatting.recordsStrings[5], recordDate: RecordsFormatting.formatOptionalDate(date: records.storedRecords[0].fastestAverageSpeedDate), firstEntry: false)
            }
            VStack {
                HStack {
                    Text("Cummulative Records")
                        .font(.headline)
                        .foregroundColor(Color(UserPreferences.convertColourChoiceToUIColor(colour: preferences.colourChoiceConverted)))
                    Spacer()
                }
                CyclingSingleRecordView(recordValue: MetricsFormatting.formatDistance(distance: records.storedRecords[0].totalCyclingDistance, usingMetric: preferences.usingMetric), recordName: RecordsFormatting.recordsStrings[0], recordDate: nil, firstEntry: true)
                CyclingSingleRecordView(recordValue: MetricsFormatting.formatTime(time: records.storedRecords[0].totalCyclingTime), recordName: RecordsFormatting.recordsStrings[1], recordDate: nil, firstEntry: false)
                CyclingSingleRecordView(recordValue: "\(records.storedRecords[0].totalCyclingRoutes)", recordName: RecordsFormatting.recordsStrings[2], recordDate: nil, firstEntry: false)
            }
        }
    }
}

struct CyclingRecordsView_Previews: PreviewProvider {
    static var previews: some View {
        CyclingRecordsView()
    }
}

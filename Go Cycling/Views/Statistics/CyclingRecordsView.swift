//
//  CyclingRecordsView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-08-30.
//

import SwiftUI

struct CyclingRecordsView: View {
    let persistenceController = PersistenceController.shared
    
    @EnvironmentObject var preferences: PreferencesStorage
    @EnvironmentObject var bikeRides: BikeRideStorage
    @EnvironmentObject var records: RecordsStorage
    
    @Environment(\.managedObjectContext) private var managedObjectContext
    var body: some View {
        VStack {
            HStack {
                Text("Cycling Records")
                    .font(.title)
                Spacer()
            }
            .padding(10)
            HStack {
                Text("Cummulative Records")
                    .font(.headline)
                Spacer()
            }
            .padding(10)
            CyclingSingleRecordView(recordValue: MetricsFormatting.formatDistance(distance: records.storedRecords[0].totalCyclingDistance, usingMetric: preferences.storedPreferences[0].usingMetric), recordName: RecordsFormatting.recordsStrings[0], recordDate: nil)
            CyclingSingleRecordView(recordValue: MetricsFormatting.formatTime(time: records.storedRecords[0].totalCyclingTime), recordName: RecordsFormatting.recordsStrings[1], recordDate: nil)
            CyclingSingleRecordView(recordValue: "\(records.storedRecords[0].totalCyclingRoutes)", recordName: RecordsFormatting.recordsStrings[2], recordDate: nil)
            HStack {
                Text("Single Route Records")
                    .font(.headline)
                Spacer()
            }
            .padding(10)
            CyclingSingleRecordView(recordValue: MetricsFormatting.formatDistance(distance: records.storedRecords[0].longestCyclingDistance, usingMetric: preferences.storedPreferences[0].usingMetric), recordName: RecordsFormatting.recordsStrings[3], recordDate: RecordsFormatting.formatOptionalDate(date: records.storedRecords[0].longestCyclingDistanceDate))
            CyclingSingleRecordView(recordValue: MetricsFormatting.formatTime(time: records.storedRecords[0].longestCyclingTime), recordName: RecordsFormatting.recordsStrings[4], recordDate: RecordsFormatting.formatOptionalDate(date: records.storedRecords[0].longestCyclingTimeDate))
            CyclingSingleRecordView(recordValue: MetricsFormatting.formatSingleSpeed(speed: records.storedRecords[0].fastestAverageSpeed, usingMetric: preferences.storedPreferences[0].usingMetric), recordName: RecordsFormatting.getFastestAvgSpeedString(usingMetric: preferences.storedPreferences[0].usingMetric), recordDate: RecordsFormatting.formatOptionalDate(date: records.storedRecords[0].fastestAverageSpeedDate))
        }
    }
}

struct CyclingRecordsView_Previews: PreviewProvider {
    static var previews: some View {
        CyclingRecordsView()
    }
}
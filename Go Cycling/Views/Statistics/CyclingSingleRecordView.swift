//
//  CyclingSingleRecordView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-08-30.
//

import SwiftUI

struct CyclingSingleRecordView: View {
    let recordValue: String
    let recordName: String
    let recordDate: String?
    let firstEntry: Bool
    
    @EnvironmentObject var newPreferences: Preferences
    
    var body: some View {
        VStack {
            HStack {
                Text(recordName)
                Spacer()
                Text(recordValue)
                    .font(.headline)
            }
            if let dateString = recordDate {
                HStack {
                    Text("Date Achieved")
                    Spacer()
                    Text(dateString)
                        .font(.headline)
                        .foregroundColor(Color(UserPreferences.convertColourChoiceToUIColor(colour: newPreferences.colourChoiceConverted)))
                }
                .padding(.top, 5)
            }
        }
        // Base padding on whether entry is first or not
        .padding(.top, firstEntry ? 5 : 10)
    }
}

struct CyclingSingleRecordView_Previews: PreviewProvider {
    static var previews: some View {
        CyclingSingleRecordView(recordValue: "Record Value", recordName: "Record Name", recordDate: "Record Date", firstEntry: false)
    }
}

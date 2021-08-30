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
    
    let persistenceController = PersistenceController.shared
    
    @EnvironmentObject var preferences: PreferencesStorage
    
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    var body: some View {
        VStack {
            HStack {
                Text(recordName)
                Spacer()
                Text(recordValue)
            }
            if let dateString = recordDate {
                HStack {
                    Text("Date Achieved")
                    Spacer()
                    Text(dateString)
                }
            }
        }
        .padding(10)
    }
}

struct CyclingSingleRecordView_Previews: PreviewProvider {
    static var previews: some View {
        CyclingSingleRecordView(recordValue: "Record Value", recordName: "Record Name", recordDate: "Record Date")
    }
}

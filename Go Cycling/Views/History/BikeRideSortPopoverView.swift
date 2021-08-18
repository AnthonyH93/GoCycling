//
//  BikeRideSortPopoverView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-08-14.
//

import SwiftUI

struct BikeRideSortPopoverView: View {
    @Binding var showingPopover: Bool
    @Binding var sortChoice: SortChoice
    
    var body: some View {
        VStack {
            Text("Sort")
                .font(.caption)
                .bold()
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 5, trailing: 0))
            Text("Set your preferred sorting order")
                .font(.caption2)
                .padding(.bottom, 10)
            Divider()
            Button("Date Descending (Default)", action: {
                showingPopover = false
                sortChoice = .dateDescending
            })
            .padding()
            Divider()
            Button("Date Ascending", action: {
                showingPopover = false
                sortChoice = .dateAscending
            })
            .padding()
            Divider()
            Button("Distance Descending", action: {
                showingPopover = false
                sortChoice = .distanceDescending
            })
            .padding()
            Divider()
        }
        VStack {
            Button("Distance Ascending", action: {
                showingPopover = false
                sortChoice = .distanceAscending
            })
            .padding()
            Divider()
            Button("Time Descending", action: {
                showingPopover = false
                sortChoice = .timeDescending
            })
            .padding()
            Divider()
            Button("Time Ascending", action: {
                showingPopover = false
                sortChoice = .timeAscending
            })
            .padding()
            Divider()
            Button("Cancel", action: {
                showingPopover = false
            })
            .padding()
            Divider()
        }
    }
}

//struct BikeRideSortPopoverView_Previews: PreviewProvider {
//    static var previews: some View {
//        BikeRideSortPopoverView()
//    }
//}

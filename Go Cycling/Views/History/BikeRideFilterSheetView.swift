//
//  BikeRideFilterSheetView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-08-14.
//

import SwiftUI

struct BikeRideFilterSheetView: View {
    let persistenceController = PersistenceController.shared
    
    @EnvironmentObject var bikeRides: BikeRideStorage

    @Environment(\.managedObjectContext) private var managedObjectContext
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var showingSheet: Bool
    @Binding private var selectedName: String
    
    var categories: [Category]
    
    init(showingSheet: Binding<Bool>, selectedName: Binding<String>, names: [Category]) {
        self._showingSheet = showingSheet
        self._selectedName = selectedName
        self.categories = names
    }
    
    var body: some View {
        VStack {
            Text("Select a Category to View")
                .font(.headline)
                .padding()
            if (self.categories.count > 0) {
                List {
                    ForEach(0 ..< self.categories.count) { index in
                        HStack {
                            Button (self.categories[index].name) {
                                self.selectedName = index == 0 ? "" : self.categories[index].name
                                self.presentationMode.wrappedValue.dismiss()
                            }
                            Spacer()
                            Text("\(self.categories[index].number)")
                        }
                    }
                }
            }
            Spacer()
            Divider()
            Button (action: {self.presentationMode.wrappedValue.dismiss()}) {
                Text("Cancel")
                    .foregroundColor(Color.red)
            }
            .padding()
            Divider()
        }
    }
}

//struct BikeRideFilterSheetView_Previews: PreviewProvider {
//    static var previews: some View {
//        BikeRideFilterSheetView()
//    }
//}

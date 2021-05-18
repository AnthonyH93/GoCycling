//
//  RouteRenameModalView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-05-17.
//

import SwiftUI
import CoreData

struct RouteRenameModalView: View {
    let persistenceController = PersistenceController.shared

    @Environment(\.managedObjectContext) private var managedObjectContext
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showModally = true
    @State private var selectedNameIndex = -1
    
    @State private var typedRouteName: String = ""
    
    @ObservedObject var routeNamingViewModel = RouteNamingViewModel()
    
    private var originalNames: [String] = []
    
    @State private var text = ""
    @State private var isEditing = false
    
    init(names: [Category]) {
        for category in names {
            if (category.name != "All" && category.name != "Uncategorized") {
                self.originalNames.append(category.name)
            }
        }
    }
    
    var body: some View {
        VStack {
            Text("Rename Your Categories")
                .font(.headline)
                .padding()
            if (routeNamingViewModel.routeNames.count > 0) {
                List {
                    ForEach(0 ..< self.routeNamingViewModel.routeNames.count) { index in
                    Button(action: {
                        self.selectedNameIndex = index
                    }) {
                        HStack {
                            if (self.selectedNameIndex == index) {
                                TextField(self.routeNamingViewModel.routeNames[index], text: $text)
                                { isEditing in
                                        self.isEditing = isEditing
                                    } onCommit: {
                                        if (text != "") {
                                            self.routeNamingViewModel.routeNames[self.selectedNameIndex] = text
                                            self.text = ""
                                        }
                                        self.selectedNameIndex = -1
                                    }
                                .border(Color(UIColor.separator))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            else {
                                Text(self.routeNamingViewModel.routeNames[index])
                            }
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .foregroundColor(.primary)
                    }
                    }
                }
            }
            else {
                Text("There are no saved categories.")
            }
            Spacer()
            Divider()
            Button (action: {self.presentationMode.wrappedValue.dismiss()}) {
                Text("Cancel")
                    .foregroundColor(Color.red)
            }
            .padding()
            Divider()
            Button (action: {self.savePressed()}) {
                Text("Save")
                    .bold()
            }
            .padding()
            .disabled(self.selectedNameIndex != -1 && !((self.text.count > 0)))
            Divider()
        }
        .presentation(isModal: self.showModally) {
        }
    }
    
    func savePressed() {
        
        if (text != "") {
            self.routeNamingViewModel.routeNames[self.selectedNameIndex] = text
            self.text = ""
        }
        self.selectedNameIndex = -1
        
        // Check what needs to be saved by comparing original names to current names
        var newNames: [String] = []
        var oldNames: [String] = []
        
        for (index, value) in self.routeNamingViewModel.routeNames.enumerated() {
            if (value != self.originalNames[index]) {
                newNames.append(value)
                oldNames.append(self.originalNames[index])
            }
        }
        
        // Need to update names
        if (newNames.count > 0) {
            for (index, name) in newNames.enumerated() {
                let context = PersistenceController.shared.container.viewContext
                let fetchRequest: NSFetchRequest<BikeRide> = BikeRide.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "cyclingRouteName == %@", oldNames[index])
                do {
                    let results = try managedObjectContext.fetch(fetchRequest)
                    for ride in results {
                        persistenceController.updateBikeRideRouteName(
                            existingBikeRide: ride,
                            latitudes: ride.cyclingLatitudes,
                            longitudes: ride.cyclingLongitudes,
                            speeds: ride.cyclingSpeeds,
                            distance: ride.cyclingDistance,
                            elevations: ride.cyclingElevations,
                            startTime: ride.cyclingStartTime,
                            time: ride.cyclingTime,
                            routeName: name)
                    }
                    try context.save()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        self.presentationMode.wrappedValue.dismiss()
    }
}

//struct RouteRenameModalView_Previews: PreviewProvider {
//    static var previews: some View {
//        RouteRenameModalView()
//    }
//}

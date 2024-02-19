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
    
    @EnvironmentObject var bikeRides: BikeRideStorage

    @Environment(\.managedObjectContext) private var managedObjectContext
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var showEditModal: Bool
    
    @State private var selectedNameIndex = -1
    
    @State private var typedRouteName: String = ""
    
    @ObservedObject var routeNamingViewModel = RouteNamingViewModel()
    
    private var originalNames: [String] = []
    
    @State private var text = ""
    @State private var isEditing = false
    
    init(showEditModal: Binding<Bool>, names: [Category]) {
        for category in names {
            if (category.name != "All" && category.name != "Uncategorized") {
                self.originalNames.append(category.name)
            }
        }
        self._showEditModal = showEditModal
    }
    
    var body: some View {
        VStack {
            Text("Rename Your Categories")
                .font(.headline)
                .padding(.top)
            Text("Tap on any category to enter a new name.")
                .padding()
            if (routeNamingViewModel.routeNames.count > 0) {
                List {
                    ForEach(0 ..< self.routeNamingViewModel.routeNames.count, id: \.self) { index in
                    Button(action: {
                        self.selectedNameIndex = index
                        self.text = ""
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
                .listStyle(PlainListStyle())
            }
            else {
                Text("There are no saved categories.")
            }
            Spacer()
            Divider()
            Button (action: {self.savePressed()}) {
                Text("Save")
            }
            .padding()
            .disabled(self.selectedNameIndex != -1 && !((self.text.count > 0)))
            Divider()
            Button (action: {self.presentationMode.wrappedValue.dismiss()}) {
                Text("Cancel")
                    .bold()
            }
            .padding()
            Divider()
        }
    }
    
    func savePressed() {
        
        self.showEditModal = false
        
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
        persistenceController.updateBikeRideCategories(oldCategoriesToUpdate: oldNames, newCategoryNames: newNames)

        self.showEditModal = false
    }
}

//struct RouteRenameModalView_Previews: PreviewProvider {
//    static var previews: some View {
//        RouteRenameModalView()
//    }
//}

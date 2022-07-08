//
//  AboutApp.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-19.
//

import SwiftUI

struct AboutAppView: View {
    
    let appVersionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    let openSourceURL = NSURL(string: "https://github.com/AnthonyH93/GoCycling")! as URL
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var isShareSheetPresented: Bool = false
    
    var body: some View {
        HStack {
            Text("App Version")
            Spacer()
            Text(appVersionNumber)
        }
        HStack {
            Text("Go Cycling is Open Source")
            Spacer()
            Button(action: {
                UIApplication.shared.open(openSourceURL, options: [:], completionHandler: nil)
            }) {
                Image(colorScheme == .dark ? "GitHub-Light" : "GitHub-Dark")
            }
        }
        Button(action: {
            self.isShareSheetPresented = true
        }) {
            Text("Share")
        }
        .sheet(isPresented: $isShareSheetPresented, onDismiss: {
        }, content: {
            ActivityViewController(activityItems: [ReviewManager.getProductURL()])
        })
        
        if let reviewURL = ReviewManager.getWriteReviewURL() {
            Link("Review Go Cycling", destination: reviewURL)
        }
    }
}

struct ActivityViewController: UIViewControllerRepresentable {

    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}

}

struct AboutApp_Previews: PreviewProvider {
    static var previews: some View {
        AboutAppView()
    }
}

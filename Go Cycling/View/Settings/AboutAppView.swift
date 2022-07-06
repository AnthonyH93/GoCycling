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
    let privacyPolicyURL = NSURL(string: "https://anthony55hopkins.wixsite.com/gocycling/privacy-policy")! as URL
    let termsAndConditionsURL = NSURL(string: "https://anthony55hopkins.wixsite.com/gocycling/terms-and-conditions")! as URL
    
    @Environment(\.colorScheme) var colorScheme
    
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
        Link("View Privacy Policy", destination: privacyPolicyURL)
        Link("View Terms and Conditions", destination: termsAndConditionsURL)
    }
}

struct AboutApp_Previews: PreviewProvider {
    static var previews: some View {
        AboutAppView()
    }
}

//
//  AboutApp.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-19.
//

import SwiftUI

struct AboutApp: View {
    let appVersionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    // Temporary place holder URLs
    let privacyPolicyURL = NSURL(string: "https://anthony55hopkins.wixsite.com/gocycling/privacy-policy")! as URL
    let termsAndConditionsURL = NSURL(string: "https://anthony55hopkins.wixsite.com/gocycling/terms-and-conditions")! as URL
    var body: some View {
        HStack {
            Text("App Version")
            Spacer()
            Text(appVersionNumber)
        }
        Link("View Privacy Policy", destination: privacyPolicyURL)
        Link("View Terms and Conditions", destination: termsAndConditionsURL)
    }
}

struct AboutApp_Previews: PreviewProvider {
    static var previews: some View {
        AboutApp()
    }
}

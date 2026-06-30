//
//  ColourView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-17.
//

import SwiftUI
import UIKit

struct ColourView: View {
    @EnvironmentObject var preferences: Preferences

    private var currentColourName: String {
        switch preferences.colourChoiceConverted {
        case .red:    return "Red"
        case .orange: return "Orange"
        case .yellow: return "Yellow"
        case .green:  return "Green"
        case .blue:   return "Blue"
        case .indigo: return "Indigo"
        case .violet: return "Violet"
        case .custom: return "Custom"
        }
    }

    var body: some View {
        NavigationLink(destination: ColourDetailView()) {
            HStack {
                Text("Colour")
                Spacer()
                Text(currentColourName)
                    .foregroundColor(.secondary)
            }
        }
    }
}

private struct ColourDetailView: View {
    @EnvironmentObject var preferences: Preferences

    let telemetryManager = TelemetryManager.sharedTelemetryManager
    let telemetryTabSection = TelemetrySettingsSection.Customization

    var colourBinding: Binding<ColourChoice> {
        Binding(
            get: { preferences.colourChoiceConverted },
            set: { value in
                preferences.updateStringPreference(preference: .colour, value: value.rawValue)
                telemetryManager.sendSettingsSignal(section: telemetryTabSection, action: TelemetrySettingsAction.Colour)
            }
        )
    }

    var customColourBinding: Binding<Color> {
        Binding(
            get: {
                if let hex = preferences.customColourHex,
                   let uiColor = UIColor(hexRGB: hex) {
                    return Color(uiColor)
                }
                return .blue
            },
            set: { color in
                let uiColor = UIColor(color)
                var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
                uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
                let hex = String(format: "%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
                preferences.updateStringPreference(preference: .customColour, value: hex)
                if preferences.colourChoiceConverted != .custom {
                    preferences.updateStringPreference(preference: .colour, value: ColourChoice.custom.rawValue)
                }
                telemetryManager.sendSettingsSignal(section: telemetryTabSection, action: TelemetrySettingsAction.Colour)
            }
        )
    }

    var body: some View {
        List {
            Section {
                Picker("Preset", selection: colourBinding) {
                    Text("Red").tag(ColourChoice.red)
                    Text("Orange").tag(ColourChoice.orange)
                    Text("Yellow").tag(ColourChoice.yellow)
                    Text("Green").tag(ColourChoice.green)
                    Text("Blue").tag(ColourChoice.blue)
                    Text("Indigo").tag(ColourChoice.indigo)
                    Text("Violet").tag(ColourChoice.violet)
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }

            Section("Custom") {
                ColorPicker("Custom Colour", selection: customColourBinding, supportsOpacity: false)
            }
        }
        .navigationBarTitle("Choose your Colour", displayMode: .inline)
    }
}

struct ColourView_Previews: PreviewProvider {
    static var previews: some View {
        ColourView()
    }
}

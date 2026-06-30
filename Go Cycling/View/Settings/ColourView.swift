//
//  ColourView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-17.
//

import SwiftUI
import UIKit

struct ColourView: View {
    let persistenceController = PersistenceController.shared

    @EnvironmentObject var preferences: Preferences
    @Environment(\.managedObjectContext) private var managedObjectContext

    let telemetryManager = TelemetryManager.sharedTelemetryManager
    let telemetryTabSection = TelemetrySettingsSection.Customization

    // Binding that drives the preset picker
    var colourBinding: Binding<ColourChoice> {
        Binding(
            get: { preferences.colourChoiceConverted },
            set: { value in
                preferences.updateStringPreference(preference: .colour, value: value.rawValue)
                telemetryManager.sendSettingsSignal(section: telemetryTabSection, action: TelemetrySettingsAction.Colour)
            }
        )
    }

    // Binding that drives the ColorPicker — reads/writes the stored hex
    var customColourBinding: Binding<Color> {
        Binding(
            get: {
                if let hex = preferences.customColourHex,
                   let uiColor = UIColor(hexRGB: hex) {
                    return Color(uiColor)
                }
                return Color.blue
            },
            set: { color in
                let uiColor = UIColor(color)
                var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
                uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
                let hex = String(format: "%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
                preferences.updateStringPreference(preference: .customColour, value: hex)
                // Ensure colour choice is set to custom
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
                Picker("Preset Colour", selection: colourBinding) {
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

            Section {
                ColorPicker("Custom Colour", selection: customColourBinding, supportsOpacity: false)
                    .onChange(of: preferences.customColourHex) { _ in
                        // Switch to custom when the picker is used
                        if preferences.colourChoiceConverted != .custom {
                            preferences.updateStringPreference(preference: .colour, value: ColourChoice.custom.rawValue)
                        }
                    }
                if preferences.colourChoiceConverted == .custom {
                    Text("Custom colour active")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } header: {
                Text("Custom")
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

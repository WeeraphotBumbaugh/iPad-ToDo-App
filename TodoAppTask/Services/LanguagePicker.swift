//
//  LanguagePicker.swift
//  TodoAppTask
//

import SwiftUI

struct LanguagePicker: View {
    @EnvironmentObject private var loc: LocalizationState

    var body: some View {
        Menu {
            Button {
                loc.code = "en"
            } label: {
                Label("🇺🇸 English", systemImage: "checkmark")
                    .opacity(loc.code == "en" ? 1 : 0).labelStyle(.titleOnly)
                Text("🇺🇸 English")
            }

            Button {
                loc.code = "fr-CA"
            } label: {
                Label("🇨🇦 Français (Canada)", systemImage: "checkmark")
                    .opacity(loc.code == "fr-CA" ? 1 : 0).labelStyle(.titleOnly)
                Text("🇨🇦 Français (Canada)")
            }

            Button {
                loc.code = "es"
            } label: {
                Label("🇪🇸 Español", systemImage: "checkmark")
                    .opacity(loc.code == "es" ? 1 : 0).labelStyle(.titleOnly)
                Text("🇪🇸 Español")
            }
        } label: {
            // Base button text
            HStack(spacing: 6) {
                Image(systemName: "globe")
                Text("Language")
            }
        }
        .accessibilityLabel(Text("Language"))
    }
}

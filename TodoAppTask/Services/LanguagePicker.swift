//
//  LanguagePicker.swift
//  TodoAppTask
//

import SwiftUI

struct LanguagePicker: View {
    @EnvironmentObject private var loc: LocalizationState

    var body: some View {
        Menu {
            LanguageOption(
                code: "en",
                title: "English",
                isSelected: loc.code == "en"
            ) {
                loc.code = "en"
            }

            LanguageOption(
                code: "fr-CA",
                title: "Français (Canada)",
                isSelected: loc.code == "fr-CA"
            ) {
                loc.code = "fr-CA"
            }

            LanguageOption(
                code: "es",
                title: "Español",
                isSelected: loc.code == "es"
            ) {
                loc.code = "es"
            }

            LanguageOption(
                code: "ar",
                title: "العربية",
                isSelected: loc.code == "ar"
            ) {
                loc.code = "ar"
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "globe")
                // This one can stay localized
                Text(String(localized: "Language"))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
        }
        .accessibilityLabel(Text("Language"))
    }
}

private struct LanguageOption: View {
    let code: String
    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                // verbatim so it never goes through localization
                Text(verbatim: title)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                }
            }
        }
    }
}

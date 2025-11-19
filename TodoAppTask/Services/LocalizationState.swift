//
//  LocalizationState.swift
//  TodoAppTask
//

import SwiftUI

final class LocalizationState: ObservableObject {
    @Published var code: String {
        didSet { UserDefaults.standard.set(code, forKey: "appLanguage") }
    }

    init() {
        self.code = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
    }

    var locale: Locale {
        Locale(identifier: code)
    }

    // Map language to layout direction so our in-app switcher can drive RTL
    var layoutDirection: LayoutDirection {
        switch code.lowercased() {
        case let value where value.hasPrefix("ar"),
             let value where value.hasPrefix("he"):
            return .rightToLeft
        default:
            return .leftToRight
        }
    }

    // Simple locale-specific accent theme
    var themeAccentColor: Color {
        switch code.lowercased() {
        case let value where value.hasPrefix("ar"):
            // You can map this to a named color in Assets if you prefer.
            return Color(red: 0.13, green: 0.52, blue: 0.43) // deep teal
        case let value where value.hasPrefix("es"):
            return .orange
        case let value where value.hasPrefix("fr"):
            return .purple
        default:
            return .cyan
        }
    }
}

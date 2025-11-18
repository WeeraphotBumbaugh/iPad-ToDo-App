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

    var locale: Locale { Locale(identifier: code) }
}

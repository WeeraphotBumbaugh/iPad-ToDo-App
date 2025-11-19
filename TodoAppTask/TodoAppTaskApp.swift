//
//  TodoAppTaskApp.swift
//  TodoAppTask
//

import SwiftUI

@main
struct TodoAppTaskApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false

    @StateObject private var localization = LocalizationState()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
                .dynamicTypeSize(.small ... .accessibility2)
                .environment(\.locale, localization.locale)
                .environment(\.layoutDirection, localization.layoutDirection)
                .environmentObject(localization)
        }
        .commands {
            CommandMenu(String(localized: "Tasks")) {
                Button(String(localized: "Toggle Sidebar")) {}
                    .keyboardShortcut("s", modifiers: [.command, .shift])
                Button(String(localized: "New Task")) {}
                    .keyboardShortcut("n", modifiers: [.command])
            }
        }
    }
}

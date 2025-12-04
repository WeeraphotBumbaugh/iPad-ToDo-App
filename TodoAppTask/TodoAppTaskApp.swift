//
//  TodoAppTaskApp.swift
//  TodoAppTask
//

import SwiftUI

@main
struct TodoAppTaskApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false

    // Localization state for runtime switching
    @StateObject private var localization = LocalizationState()
    
    // Pro membership state
    @StateObject private var storeManager = StoreManager()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
                .dynamicTypeSize(.small ... .accessibility2)
                .environment(\.locale, localization.locale)
                .environmentObject(localization)
                .environmentObject(storeManager)
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

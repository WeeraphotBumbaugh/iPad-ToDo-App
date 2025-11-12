//
//  TodoAppTaskApp.swift
//  TodoAppTask
//

import SwiftUI

@main
struct TodoAppTaskApp: App {
    // Register UIKit app delegate to supply scene configurations.
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
                .dynamicTypeSize(.small ... .accessibility2)
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

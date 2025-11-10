//
//  TodoAppTaskApp.swift
//  TodoAppTask
//

import SwiftUI

@main
struct TodoAppTaskApp: App {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
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

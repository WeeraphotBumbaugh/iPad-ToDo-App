//
//  ProfileView.swift
//  TodoAppTask
//

import SwiftUI

struct ProfileView: View {
    var appAccentColor: Color
    @Binding var isDarkMode: Bool
    @Binding var profileName: String
    
    // Fixed creation date: Oct 7, 1996 at 12:00 UTC to avoid TZ shift
    private let createdAt: Date = {
        var comps = DateComponents()
        comps.calendar = Calendar(identifier: .gregorian)
        comps.timeZone = TimeZone(secondsFromGMT: 0)
        comps.year = 1996
        comps.month = 10
        comps.day = 7
        comps.hour = 12
        return comps.date ?? Date(timeIntervalSince1970: 845380800) // fallback
    }()

    var body: some View {
        NavigationStack {
            Form {
                Section(String(localized: "Profile")) {
                    HStack {
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: 48))
                            .foregroundStyle(appAccentColor)
                        TextField(String(localized: "Name"), text: $profileName)
                            .textInputAutocapitalization(.words)
                    }
                }

                Section(String(localized: "Appearance")) {
                    Toggle(isOn: $isDarkMode) {
                        Label(String(localized: "Dark Mode"),
                              systemImage: isDarkMode ? "moon.fill" : "sun.max.fill")
                    }
                    .tint(appAccentColor)
                }

                Section(String(localized: "Preferences")) {
                    Label(String(localized: "Notifications"), systemImage: "bell.badge.fill")
                    Label(String(localized: "Settings"), systemImage: "gear")
                }

                Section(String(localized: "Account")) {
                    HStack {
                        Label(String(localized: "Created At"), systemImage: "calendar")
                        Spacer()
                        Text(createdAt, format: .dateTime
                            .year().month(.abbreviated).day())
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                    }
                    Label(String(localized: "Sign Out"), systemImage: "arrow.right.to.line.circle.fill")
                        .foregroundStyle(.red)
                }
            }
            .navigationTitle(String(localized: "My Profile"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

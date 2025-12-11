//
//  ProfileView.swift
//  TodoAppTask
//

import SwiftUI

struct ProfileView: View {
    var appAccentColor: Color
    @Binding var isDarkMode: Bool
    @Binding var profileName: String
    @Binding var isPremiumUser: Bool
    
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
                // MARK: - Profile
                Section(String(localized: "Profile")) {
                    HStack {
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: 48))
                            .foregroundStyle(appAccentColor)
                        TextField(String(localized: "Name"), text: $profileName)
                            .textInputAutocapitalization(.words)
                    }
                }

                // MARK: - Appearance
                Section(String(localized: "Appearance")) {
                    Toggle(isOn: $isDarkMode) {
                        Label(String(localized: "Dark Mode"),
                              systemImage: isDarkMode ? "moon.fill" : "sun.max.fill")
                    }
                    .tint(appAccentColor)
                }

                // MARK: - Upgrade / Premium
                Section(String(localized: "Upgrade")) {
                    if isPremiumUser {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                            Text(String(localized: "Premium Unlocked"))
                                .font(.headline)
                        }

                        Text(
                            String(
                                localized: "You can create unlimited Main Groups and Task Groups. Thank you for supporting the app."
                            )
                        )
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    } else {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: "star.circle.fill")
                                    .foregroundStyle(appAccentColor)
                                Text(String(localized: "Premium Groups Upgrade"))
                                    .font(.headline)
                            }

                            Text(
                                String(
                                    localized: "Free plan includes up to 3 Task Groups and 2 Main Groups. Upgrade for unlimited groups and more flexible organization."
                                )
                            )
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                            Text(
                                String(
                                    localized: "One-time purchase: $3.99"
                                )
                            )
                            .font(.footnote.weight(.semibold))
                        }

                        Button {
                            // Placeholder for real in-app purchase.
                            withAnimation {
                                isPremiumUser = true
                            }
                        } label: {
                            Text(String(localized: "Upgrade to Premium"))
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(appAccentColor)
                        .accessibilityIdentifier("upgradeToPremiumButton")
                    }
                }

                // MARK: - Preferences
                Section(String(localized: "Preferences")) {
                    Label(String(localized: "Notifications"), systemImage: "bell.badge.fill")
                    Label(String(localized: "Settings"), systemImage: "gear")
                }

                // MARK: - Account Info
                Section(String(localized: "Account")) {
                    HStack {
                        Label(String(localized: "Created At"), systemImage: "calendar")
                        Spacer()
                        Text(
                            createdAt,
                            format: .dateTime
                                .year()
                                .month(.abbreviated)
                                .day()
                        )
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

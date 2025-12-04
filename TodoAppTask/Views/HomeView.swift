//
//  HomeView.swift
//  TodoAppTask
//
//  Created by Weeraphot Bumbaugh on 11/12/25.
//

import SwiftUI

struct HomeView: View {
    private let profiles = [
        ProfileCategory(name: "School", imageName: "SchoolCover", storageKey: "school_data"),
        ProfileCategory(name: "Work", imageName: "WorkCover", storageKey: "work_data"),
        ProfileCategory(name: "Personal", imageName: "PersonalCover", storageKey: "personal_data")
    ]

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    @EnvironmentObject private var loc: LocalizationState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 40) {
                    welcomeHeader
                    profileGrid
                    languageSection
                }
                .padding(.bottom, 24)
            }
            .navigationTitle(String(localized: "Home"))
            .navigationBarHidden(true)
        }
    }

    private var welcomeHeader: some View {
        VStack(spacing: 10) {
            Image(systemName: "person.crop.circle.badge.checkmark")
                .font(.system(size: 80))
                .foregroundStyle(.cyan)

            Text(String(localized: "Welcome Back"))
                .font(.largeTitle.bold())

            Text(String(localized: "Select a workspace to begin"))
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 50)
    }

    private var profileGrid: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(profiles) { profile in
                NavigationLink(
                    destination: ContentView(
                        storageKey: profile.storageKey,
                        profileTitle: profile.name
                    )
                ) {
                    ProfileCard(profile: profile)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier(profile.storageKey)
            }
        }
        .padding(.horizontal, 80)
    }

    // Language selector + "current language" label
    private var languageSection: some View {
        VStack(spacing: 12) {
            LanguagePicker()

            Text(verbatim: currentLanguageLabel(code: loc.code))
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .accessibilityLabel(Text("Language"))
    }

    private func currentLanguageLabel(code: String) -> String {
        switch code {
        case "en":
            return String(localized: "Current: English")
        case "fr-CA":
            return String(localized: "Current: Français (Canada)")
        case "es":
            return String(localized: "Current: Español")
        case "ar":
            return String(localized: "Current: العربية")
        default:
            return String(localized: "Current: English")
        }
    }
}

struct ProfileCard: View {
    let profile: ProfileCategory

    var body: some View {
        VStack {
            Image(profile.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 140)
                .clipped()
                .overlay(Color.black.opacity(0.2))
            HStack {
                Text(profile.name)
                    .font(.title3.bold())
                    .foregroundStyle(.primary)

                Spacer()

                Image(systemName: "chevron.right.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.cyan)
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
        }
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.5), lineWidth: 1)
        )
    }
}

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
                    languageMenu // dropdown at the base
                }
                .padding(.bottom, 24)
            }
            .navigationTitle("Home")
            .navigationBarHidden(true)
        }
    }

    private var welcomeHeader: some View {
        VStack(spacing: 10) {
            Image(systemName: "person.crop.circle.badge.checkmark")
                .font(.system(size: 80))
                .foregroundStyle(.cyan)

            Text("Welcome Back")
                .font(.largeTitle.bold())

            Text("Select a workspace to begin")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 50)
    }

    private var profileGrid: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(profiles) { profile in
                NavigationLink(destination: ContentView(storageKey: profile.storageKey, profileTitle: profile.name)) {
                    ProfileCard(profile: profile)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 80)
    }

    // Language dropdown with flags and text
    private var languageMenu: some View {
        VStack(spacing: 12) {
            Menu {
                Button {
                    loc.code = "en"
                } label: {
                    HStack {
                        Text("🇺🇸")
                        Text("English")
                        if loc.code == "en" { Spacer(); Image(systemName: "checkmark") }
                    }
                }

                Button {
                    loc.code = "fr-CA"
                } label: {
                    HStack {
                        Text("🇨🇦")
                        Text("Français (Canada)")
                        if loc.code == "fr-CA" { Spacer(); Image(systemName: "checkmark") }
                    }
                }

                Button {
                    loc.code = "es"
                } label: {
                    HStack {
                        Text("🇪🇸")
                        Text("Español")
                        if loc.code == "es" { Spacer(); Image(systemName: "checkmark") }
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "globe")
                    Text("Language")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
            }

            Text(currentLanguageLabel(code: loc.code))
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .accessibilityLabel(Text("Language"))
    }

    private func currentLanguageLabel(code: String) -> String {
        switch code {
        case "en": return "Current: English"
        case "fr-CA": return "Current: Français (Canada)"
        case "es": return "Current: Español"
        default: return "Current: English"
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

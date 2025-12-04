//
//  ManageGroupsView.swift
//  TodoAppTask
//

import SwiftUI

struct ManageGroupsView: View {

    var appAccentColor: Color
    @Binding var mains: [MainTaskGroup]

    // Total existing TaskGroups in the app (passed from ContentView)
    var currentGroupCount: Int

    var onCreate: (String, String, ParentChoice) -> Void

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var storeManager: StoreManager

    @State private var newGroupName: String = ""
    @State private var newGroupIcon: String = "checklist"

    // Parent choice UI
    enum AttachMode: String, CaseIterable, Identifiable {
        case auto, existing, newParent
        var id: String { rawValue }
    }
    @State private var attachMode: AttachMode = .auto
    @State private var selectedMainID: MainTaskGroup.ID?
    @State private var newParentTitle: String = ""
    @State private var newParentSymbol: String = "folder"

    @State private var showUpgradeAlert = false

    private let groupIcons = [
        "checklist", "star.fill", "briefcase.fill", "heart.fill",
        "book.fill", "house.fill", "person.fill", "cart.fill",
        "airplane", "banknote.fill"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section(String(localized: "Add New Group")) {
                    TextField(String(localized: "Group Name (e.g., Work)"), text: $newGroupName)
                        .accessibilityIdentifier("newGroupNameTestField")

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(groupIcons, id: \.self) { icon in
                                Button {
                                    newGroupIcon = icon
                                } label: {
                                    Image(systemName: icon)
                                        .font(.title2)
                                        .foregroundStyle(newGroupIcon == icon ? .white : appAccentColor)
                                        .frame(width: 44, height: 44)
                                        .background(newGroupIcon == icon ? appAccentColor : Color(.systemGray5))
                                        .clipShape(Circle())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section(String(localized: "Attach To")) {
                    Picker(String(localized: "Mode"), selection: $attachMode) {
                        Text(String(localized: "Auto")).tag(AttachMode.auto)
                        Text(String(localized: "Existing Parent")).tag(AttachMode.existing)
                        Text(String(localized: "New Parent")).tag(AttachMode.newParent)
                    }
                    .pickerStyle(.segmented)

                    switch attachMode {
                    case .auto:
                        Text(String(localized: "Will attach to the first parent, or create a default one."))
                            .foregroundStyle(.secondary)

                    case .existing:
                        if mains.isEmpty {
                            Text(String(localized: "No parents yet. Choose New Parent or Auto."))
                                .foregroundStyle(.secondary)
                        } else {
                            Picker(String(localized: "Parent"), selection: $selectedMainID) {
                                ForEach(mains) { main in
                                    Text(main.title).tag(Optional(main.id))
                                }
                            }
                        }

                    case .newParent:
                        TextField(String(localized: "Parent Title (e.g., My Groups)"), text: $newParentTitle)
                        TextField(String(localized: "Parent Symbol (SF Symbol, e.g., folder)"),
                                  text: $newParentSymbol)
                            .textInputAutocapitalization(.never)
                    }
                }
            }
            .navigationTitle(String(localized: "Manage Groups"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Done")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        createTapped()
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text(String(localized: "Add New Group"))
                                .accessibilityIdentifier("addNewGroupButton2")

                        }
                    }
                    .disabled(newGroupName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                              || (attachMode == .existing && selectedMainID == nil)
                              || (attachMode == .newParent && newParentTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty))
                }
            }
            .alert(String(localized: "Upgrade to Pro"), isPresented: $showUpgradeAlert) {
                Button(String(localized: "Upgrade for $5.99")) {
                    storeManager.buyProVersion()
                }
                Button(String(localized: "Cancel"), role: .cancel) { }
            } message: {
                Text(String(localized: "You’ve reached the free limit for groups or main groups. Upgrade to Pro to unlock unlimited groups."))
            }
        }
        .tint(appAccentColor)
    }

    private func createTapped() {
        let title = newGroupName.trimmingCharacters(in: .whitespacesAndNewlines)
        let symbol = newGroupIcon

        // Enforce group limit BEFORE creating anything
        guard storeManager.canAddGroup(currentGroupCount: currentGroupCount) else {
            showUpgradeAlert = true
            return
        }

        // If user is trying to create a brand new parent, also enforce main-group limit
        if attachMode == .newParent && !storeManager.canAddMainGroup(currentMainCount: mains.count) {
            showUpgradeAlert = true
            return
        }

        let parent: ParentChoice
        switch attachMode {
        case .auto:
            parent = .auto
        case .existing:
            if let id = selectedMainID {
                parent = .existing(id)
            } else {
                return
            }
        case .newParent:
            let pTitle = newParentTitle.trimmingCharacters(in: .whitespacesAndNewlines)
            let pSymbol = newParentSymbol.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "folder" : newParentSymbol
            parent = .newParent(title: pTitle, symbol: pSymbol)
        }

        onCreate(title, symbol, parent)

        // reset inputs for a clean next entry
        newGroupName = ""
        newGroupIcon = "checklist"
        selectedMainID = nil
        newParentTitle = ""
        newParentSymbol = "folder"

        dismiss()
    }
}

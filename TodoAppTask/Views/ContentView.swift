//
//  ContentView.swift
//  TodoAppTask
//

import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.horizontalSizeClass) private var hSizeClass

    @State private var selection: SidebarSelection? = nil
    @State private var taskGroups: [TaskGroup] = []
    @State private var mainTaskGroups: [MainTaskGroup] = []
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var isManagingGroups = false

    @AppStorage("profileName") private var profileName = "Weeraphot Bumbaugh"
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @AppStorage("isPremiumUser") private var isPremiumUser: Bool = false

    private let appAccentColor = Color.cyan
    private var taskGroupsKey: String { "taskGroupsData_\(storageKey)" }
    private var mainTaskGroupsKey: String { "mainTaskGroupsData_\(storageKey)" }

    var storageKey: String
    var profileTitle: LocalizedStringKey

    private var sidebarNodes: [SidebarNode] {
        buildSidebarNodes()
    }

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            sidebarView
        } detail: {
            detailView
        }
        .navigationSplitViewStyle(.balanced)
        .navigationSplitViewColumnWidth(min: 0, ideal: 250, max: 300)
        .sheet(isPresented: $isManagingGroups) {
            ManageGroupsView(
                appAccentColor: appAccentColor,
                mains: $mainTaskGroups,
                currentGroupCount: taskGroups.count
            ) { title, symbol, parent in
                addTaskGroup(title: title, symbolName: symbol, parent: parent)
            }
        }
        .tint(appAccentColor)
        .dynamicTypeSize(.small ... .accessibility2)
        .onAppear {
            loadTaskGroups()
            loadMainTaskGroups()
            if selection == nil {
                if let gid = mainTaskGroups.first?.taskGroupIDs.first,
                   taskGroups.contains(where: { $0.id == gid }) {
                    selection = .group(gid)
                } else if let any = taskGroups.first?.id {
                    selection = .group(any)
                } else {
                    selection = .profile
                }
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                saveTaskGroups()
                saveMainTaskGroups()
            }
        }
        .task {
            if hSizeClass == .compact {
                columnVisibility = .automatic
            }
        }
    }

    // MARK: - Split views

    private var sidebarView: some View {
        List(selection: $selection) {
            Section {
                OutlineGroup(sidebarNodes, children: \.children) { node in
                    Row(node: node, appAccentColor: appAccentColor)
                }
            } header: {
                Text(String(localized: "My Tasks"))
                    .font(.headline)
                    .foregroundStyle(appAccentColor)
                    .multilineTitle()
            }

            Section(String(localized: "Account")) {
                NavigationLink(value: SidebarSelection.profile) {
                    Label {
                        Text(profileName).multilineTitle()
                    } icon: {
                        Image(systemName: "person.crop.circle")
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .listStyle(.sidebar)
        .padding(.top, -20)
        .toolbar {
            toolbarContent
        }
    }

    private var detailView: some View {
        Group {
            switch selection {
            case .group(let groupID):
                if let index = taskGroups.firstIndex(where: { $0.id == groupID }) {
                    TaskGroupDetailView(
                        group: $taskGroups[index],
                        appAccentColor: appAccentColor
                    )
                } else {
                    ContentUnavailableView(
                        String(localized: "Group Deleted"),
                        systemImage: "nosign",
                        description: Text(
                            String(localized: "The selected group no longer exists. Please select another one.")
                        )
                    )
                    .foregroundStyle(.secondary)
                }

            case .profile:
                ProfileView(
                    appAccentColor: appAccentColor,
                    isDarkMode: $isDarkMode,
                    profileName: $profileName,
                    isPremiumUser: $isPremiumUser
                )

            case nil:
                ContentUnavailableView(
                    String(localized: "Welcome"),
                    systemImage: "checklist.unchecked",
                    description: Text(
                        String(localized: "Select a group from the sidebar to get started")
                    )
                )
                .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        // Center title
        ToolbarItem(placement: .principal) {
            Text(String(localized: "My TODO Tracker"))
                .font(.headline)
                .multilineTitle()
        }

        // Manage Groups
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                isManagingGroups = true
            } label: {
                Image(systemName: "plus")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(appAccentColor)
                    .padding(6)
                    .background(appAccentColor.opacity(0.15))
                    .clipShape(Circle())
                    .accessibilityIdentifier("addNewGroupButton")
            }
            .help(String(localized: "Manage Groups"))
        }
    }

    // MARK: - Row
    private struct Row: View {
        let node: SidebarNode
        let appAccentColor: Color

        var body: some View {
            if let kids = node.children, !kids.isEmpty {
                // MAIN GROUP ROW
                Label {
                    Text(node.title).multilineTitle()
                } icon: {
                    Image(systemName: node.symbolName)
                }
                .padding(.vertical, 4)
                .contextMenu {
                    Button(String(localized: "Delete"), role: .destructive) {
                        NotificationCenter.default.post(
                            name: .deleteMainByID,
                            object: node.id
                        )
                    }
                }
            } else {
                // CHILD GROUP ROW
                NavigationLink(value: node.selection) {
                    Label {
                        Text(node.title).multilineTitle()
                    } icon: {
                        Image(systemName: node.symbolName)
                    }
                    .padding(.vertical, 4)
                }
                .accessibilityIdentifier("\(node.title)")
                .contextMenu {
                    if case .group(let gid) = node.selection {
                        Button(String(localized: "Delete"), role: .destructive) {
                            NotificationCenter.default.post(
                                name: .deleteGroupByID,
                                object: gid
                            )
                        }
                    }
                }
            }
        }
    }

    // MARK: - Sidebar building
    private func buildSidebarNodes() -> [SidebarNode] {
        mainTaskGroups.map { main in
            let kids: [SidebarNode] = main.taskGroupIDs.compactMap { gid in
                guard let group = taskGroups.first(where: { $0.id == gid }) else { return nil }
                return SidebarNode(
                    id: group.id,
                    title: group.title,
                    symbolName: group.symbolName,
                    selection: .group(group.id),
                    children: nil
                )
            }

            let defaultSelection: SidebarSelection = {
                if let firstKid = kids.first { return firstKid.selection }
                if let anyGroup = taskGroups.first { return .group(anyGroup.id) }
                return .profile
            }()

            return SidebarNode(
                id: main.id,
                title: main.title,
                symbolName: main.symbolName,
                selection: defaultSelection,
                children: kids.isEmpty ? nil : kids
            )
        }
    }

    // MARK: - Persistence
    private func loadTaskGroups() {
        if let data = UserDefaults.standard.data(forKey: taskGroupsKey),
           let decoded = try? JSONDecoder().decode([TaskGroup].self, from: data) {
            taskGroups = decoded
        } else {
            taskGroups = []
        }

        NotificationCenter.default.addObserver(
            forName: .deleteGroupByID,
            object: nil,
            queue: .main
        ) { note in
            guard
                let gid = note.object as? TaskGroup.ID,
                let group = taskGroups.first(where: { $0.id == gid })
            else { return }
            deleteGroup(group)
        }
    }

    private func loadMainTaskGroups() {
        if let data = UserDefaults.standard.data(forKey: mainTaskGroupsKey),
           let decoded = try? JSONDecoder().decode([MainTaskGroup].self, from: data) {
            mainTaskGroups = decoded
        } else {
            mainTaskGroups = []
        }

        NotificationCenter.default.addObserver(
            forName: .deleteMainByID,
            object: nil,
            queue: .main
        ) { note in
            guard
                let mid = note.object as? MainTaskGroup.ID,
                let main = mainTaskGroups.first(where: { $0.id == mid })
            else { return }
            deleteMain(main)
        }
    }

    private func saveTaskGroups() {
        if let data = try? JSONEncoder().encode(taskGroups) {
            UserDefaults.standard.set(data, forKey: taskGroupsKey)
        }
    }

    private func saveMainTaskGroups() {
        if let data = try? JSONEncoder().encode(mainTaskGroups) {
            UserDefaults.standard.set(data, forKey: mainTaskGroupsKey)
        }
    }

    // Delete a TaskGroup (sub-group) and detach from all parents
    private func deleteGroup(_ group: TaskGroup) {
        if selection == .group(group.id) { selection = nil }
        taskGroups.removeAll { $0.id == group.id }
        for i in mainTaskGroups.indices {
            mainTaskGroups[i].taskGroupIDs.removeAll { $0 == group.id }
        }
        saveTaskGroups()
        saveMainTaskGroups()
    }

    // Delete a MainTaskGroup (parent) and cascade-delete orphaned child groups
    private func deleteMain(_ main: MainTaskGroup) {
        mainTaskGroups.removeAll { $0.id == main.id }

        for gid in main.taskGroupIDs {
            let stillReferencedElsewhere = mainTaskGroups.contains { $0.taskGroupIDs.contains(gid) }

            if !stillReferencedElsewhere,
               let group = taskGroups.first(where: { $0.id == gid }) {
                deleteGroup(group)
            }
        }

        if case .group(let gid) = selection,
           !taskGroups.contains(where: { $0.id == gid }) {
            if let any = taskGroups.first?.id {
                selection = .group(any)
            } else {
                selection = .profile
            }
        }

        saveMainTaskGroups()
    }

    private func addTaskGroup(title: String, symbolName: String, parent: ParentChoice) {
        let newGroup = TaskGroup(title: title, symbolName: symbolName, tasks: [])
        taskGroups.append(newGroup)

        switch parent {
        case .existing(let mainID):
            if let i = mainTaskGroups.firstIndex(where: { $0.id == mainID }) {
                if !mainTaskGroups[i].taskGroupIDs.contains(newGroup.id) {
                    mainTaskGroups[i].taskGroupIDs.append(newGroup.id)
                }
            }
        case .newParent(let title, let symbol):
            let newMain = MainTaskGroup(
                title: title,
                symbolName: symbol,
                taskGroupIDs: [newGroup.id]
            )
            mainTaskGroups.append(newMain)
        case .auto:
            if mainTaskGroups.isEmpty {
                let defaultMain = MainTaskGroup(
                    title: String(localized: "My Groups"),
                    symbolName: "folder",
                    taskGroupIDs: [newGroup.id]
                )
                mainTaskGroups.append(defaultMain)
            } else if !mainTaskGroups[0].taskGroupIDs.contains(newGroup.id) {
                mainTaskGroups[0].taskGroupIDs.append(newGroup.id)
            }
        }

        saveTaskGroups()
        saveMainTaskGroups()
        selection = .group(newGroup.id)
    }
}

// MARK: - Helpers

private extension Notification.Name {
    static let deleteGroupByID = Notification.Name("deleteGroupByID")
    static let deleteMainByID = Notification.Name("deleteMainByID")
}

// MARK: - Multiline support

struct MultilineTitle: ViewModifier {
    var lines: Int = 2
    var minScale: CGFloat = 0.85
    func body(content: Content) -> some View {
        content
            .lineLimit(lines)
            .minimumScaleFactor(minScale)
            .multilineTextAlignment(.leading)
            .allowsTightening(true)
            .truncationMode(.tail)
    }
}

extension View {
    func multilineTitle(lines: Int = 2, minScale: CGFloat = 0.85) -> some View {
        modifier(MultilineTitle(lines: lines, minScale: minScale))
    }
}

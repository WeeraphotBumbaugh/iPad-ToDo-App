//
//  ContentView.swift
//  TodoAppTask
//

import SwiftUI
import PencilKit

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

    private let appAccentColor = Color.cyan
    private let taskGroupsKey = "taskGroupsData"
    private let mainTaskGroupsKey = "mainTaskGroupsData"
    
    var storageKey: String
    var profileTitle: LocalizedStringKey

    var body: some View {
        let nodes = buildSidebarNodes()

        NavigationSplitView(columnVisibility: $columnVisibility) {

            // SIDEBAR
            List(selection: $selection) {
                Section {
                    OutlineGroup(nodes, children: \.children) { node in
                        Row(node: node, appAccentColor: appAccentColor)
                    }
                } header: {
                    Text("My Tasks")
                        .font(.headline)
                        .foregroundStyle(appAccentColor)
                        .multilineTitle()
                }

                Section("Account") {
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
            .navigationTitle("My TODO Tracker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("My TODO Tracker")
                        .font(.headline)
                        .multilineTitle()
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        withAnimation {
                            columnVisibility = (columnVisibility == .all) ? .detailOnly : .all
                        }
                    } label: { Image(systemName: "sidebar.leading") }
                    .keyboardShortcut("s", modifiers: [.command, .shift])
                    .help("Toggle Sidebar")
                }
                ToolbarItem(placement: .primaryAction) {
                    Button { isManagingGroups = true } label: {
                        Image(systemName: "plus")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(appAccentColor)
                            .padding(6)
                            .background(appAccentColor.opacity(0.15))
                            .clipShape(Circle())
                    }
                    .help("Manage Groups")
                }
            }

        } detail: {
            // DETAIL
            switch selection {
            case .group(let groupID):
                if let index = taskGroups.firstIndex(where: { $0.id == groupID }) {
                    TaskGroupDetailView(group: $taskGroups[index], appAccentColor: appAccentColor)
                } else {
                    ContentUnavailableView(
                        "Group Deleted",
                        systemImage: "nosign",
                        description: Text("The selected group no longer exists. Please select another one.")
                    )
                    .foregroundStyle(.secondary)
                }

            case .profile:
                ProfileView(appAccentColor: appAccentColor,
                            isDarkMode: $isDarkMode,
                            profileName: $profileName)

            case nil:
                ContentUnavailableView(
                    "Welcome",
                    systemImage:"checklist.unchecked",
                    description: Text("Select a group from the sidebar to get started")
                )
                .foregroundStyle(.secondary)
            }
        }
        .navigationSplitViewStyle(.balanced)
        .sheet(isPresented: $isManagingGroups) {
            ManageGroupsView(
                appAccentColor: appAccentColor,
                mains: $mainTaskGroups
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
            if hSizeClass == .compact { columnVisibility = .automatic }
        }
    }

    // MARK: - Row
    private struct Row: View {
        let node: SidebarNode
        let appAccentColor: Color
        var body: some View {
            if let kids = node.children, !kids.isEmpty {
                Label {
                    Text(node.title).multilineTitle()
                } icon: {
                    Image(systemName: node.symbolName)
                }
                .padding(.vertical, 4)
            } else {
                NavigationLink(value: node.selection) {
                    Label {
                        Text(node.title).multilineTitle()
                    } icon: {
                        Image(systemName: node.symbolName)
                    }
                    .padding(.vertical, 4)
                }
                .contextMenu {
                    if case .group(let gid) = node.selection {
                        Button("Delete", role: .destructive) {
                            NotificationCenter.default.post(name: .deleteGroupByID, object: gid)
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
                return SidebarNode(id: group.id,
                                   title: group.title,
                                   symbolName: group.symbolName,
                                   selection: .group(group.id),
                                   children: nil)
            }

            let defaultSelection: SidebarSelection = {
                if let firstKid = kids.first { return firstKid.selection }
                if let anyGroup = taskGroups.first { return .group(anyGroup.id) }
                return .profile
            }()

            return SidebarNode(id: main.id,
                               title: main.title,
                               symbolName: main.symbolName,
                               selection: defaultSelection,
                               children: kids.isEmpty ? nil : kids)
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

        NotificationCenter.default.addObserver(forName: .deleteGroupByID, object: nil, queue: .main) { note in
            guard let gid = note.object as? TaskGroup.ID,
                  let group = taskGroups.first(where: { $0.id == gid }) else { return }
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

    private func deleteGroup(_ group: TaskGroup) {
        if selection == .group(group.id) { selection = nil }
        taskGroups.removeAll { $0.id == group.id }
        for i in mainTaskGroups.indices {
            mainTaskGroups[i].taskGroupIDs.removeAll { $0 == group.id }
        }
        saveTaskGroups()
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
            let newMain = MainTaskGroup(title: title, symbolName: symbol, taskGroupIDs: [newGroup.id])
            mainTaskGroups.append(newMain)
        case .auto:
            if mainTaskGroups.isEmpty {
                let defaultMain = MainTaskGroup(title: "My Groups",
                                                symbolName: "folder",
                                                taskGroupIDs: [newGroup.id])
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

// MARK: - Profile

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
        return comps.date ?? Date(timeIntervalSince1970: 845380800)
    }()

    var body: some View {
        NavigationStack {
            Form {
                Section("Profile") {
                    HStack {
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: 48))
                            .foregroundStyle(appAccentColor)
                        TextField("Name", text: $profileName)
                            .textInputAutocapitalization(.words)
                    }
                }

                Section("Appearance") {
                    Toggle(isOn: $isDarkMode) {
                        Label("Dark Mode",
                              systemImage: isDarkMode ? "moon.fill" : "sun.max.fill")
                    }
                    .tint(appAccentColor)
                }

                Section("Preferences") {
                    Label("Notifications", systemImage: "bell.badge.fill")
                    Label("Settings", systemImage: "gear")
                }

                Section("Account") {
                    HStack {
                        Label("Created At", systemImage: "calendar")
                        Spacer()
                        Text(createdAt, format: .dateTime
                            .year().month(.abbreviated).day())
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                    }
                    Label("Sign Out", systemImage: "arrow.right.to.line.circle.fill")
                        .foregroundStyle(.red)
                }
            }
            .navigationTitle("My Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Helpers

private extension Notification.Name {
    static let deleteGroupByID = Notification.Name("deleteGroupByID")
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

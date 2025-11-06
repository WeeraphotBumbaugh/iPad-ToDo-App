//
//  ContentView.swift
//  TodoAppTask
//
//  Created by SDGKU on 01/11/25.
//

import SwiftUI

struct ContentView: View {
    
    @State private var selection: SidebarSelection? = .group(sampleTaskGroups[0].id)
    @State private var taskGroups = sampleTaskGroups
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var isManagingGroups = false
    private var appAccentColor = Color.cyan
    
    var body: some View {
        
        NavigationSplitView(columnVisibility: $columnVisibility) {
            
            List(selection: $selection) {
                Section {
                    ForEach(taskGroups) { group in
                        NavigationLink(value: SidebarSelection.group(group.id)) {
                            Label(group.title, systemImage: group.symbolName)
                                .padding(.vertical, 4)
                        }
                        .contextMenu {
                            Button("Delete", role: .destructive) {
                                deleteGroup(group)
                            }
                        }
                    }
                } header: {
                    Text("My Tasks")
                        .font(.headline)
                        .foregroundStyle(appAccentColor)
                }

                
                Section("Account") {
                    NavigationLink(value: SidebarSelection.profile) {
                        Label("Gabriela Sanchez", systemImage: "person.crop.circle")
                            .padding(.vertical, 4)
                    }
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("My TODO Tracker")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isManagingGroups = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(appAccentColor)
                            .padding(6)
                            .background(appAccentColor.opacity(0.15))
                            .clipShape(Circle())
                    }
                }
            }
            
        } detail: {
            
            switch selection {
                
            case .group(let groupID):
                if let index = taskGroups.firstIndex(where: { $0.id == groupID }) {
                    TaskGroupDetailView(group: $taskGroups[index], appAccentColor: appAccentColor)
                } else {
                    ContentUnavailableView(
                        "Group Deleted",
                        systemImage: "nosign",
                        description: Text("The selected group no longer exists. Please select another one."))
                    .foregroundStyle(.secondary)
                }
                
            case .profile:
                ProfileView(appAccentColor: appAccentColor)
                
            case nil:
                ContentUnavailableView(
                    "Welcome",
                    systemImage:"checklist.unchecked",
                    description: Text("Select a group from the side bar to get started"))
                .foregroundStyle(.secondary)
            }
        }
        .sheet(isPresented: $isManagingGroups) {
            ManageGroupsView(groups: $taskGroups, appAccentColor: appAccentColor)
        }
        .tint(appAccentColor)
    }
    
    private func deleteGroup(_ group: TaskGroup) {
        if selection == .group(group.id) {
            selection = nil
        }
        taskGroups.removeAll { $0.id == group.id }
    }
}

// MARK: - Sample Data

var sampleTaskGroups: [TaskGroup] = [
    TaskGroup(title: "Homework SDGKU", symbolName: "books.vertical.fill", tasks: [
        TaskItem(title: "Upload Assigment to Canvas", isCompleted: false),
        TaskItem(title: "Implement Login View", isCompleted: false)
    ]),
    TaskGroup(title: "House Groceries", symbolName: "house.fill", tasks: [
        TaskItem(title: "Go groceries shopping", isCompleted: true),
        TaskItem(title: "Buy milk", isCompleted: false),
        TaskItem(title: "Buy eggs", isCompleted: false)
    ])
]


struct ProfileView: View {
    
    var appAccentColor: Color

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: 120))
                        .foregroundStyle(appAccentColor)
                        .shadow(color: appAccentColor.opacity(0.3), radius: 10, y: 5)
                        .padding(.top, 40)
                    
                    VStack(spacing: 4) {
                        Text("Gabriela Sanchez")
                            .font(.largeTitle.weight(.bold))
                        Text("Professor")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.bottom, 20)
                    
                    List {
                        Section("Preferences") {
                            Label("Settings", systemImage: "gear")
                            Label("Notifications", systemImage: "bell.badge.fill")
                        }
                        
                        Section("Account") {
                            Label("Sign Out", systemImage: "arrow.right.to.line.circle.fill")
                                .foregroundStyle(.red)
                        }
                    }
                    .listStyle(.insetGrouped)
                    .frame(height: 280)
                    .scrollDisabled(true)

                }
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("My Profile")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground))
        }
    }
}

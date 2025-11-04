//
//  ContentView.swift
//  TodoApp2
//
//  Created by Gabriela Sanchez on 03/11/25.
//

import SwiftUI

struct ContentView: View {
    
    @State private var selection: SideBarSelection? = .group(sampleTaskGroups[0].id)
    @State private var taskGroups = sampleTaskGroups
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
        
    // 1. Add @State to control the presentation of our new sheet
    @State private var isManagingGroups = false
    
    var body: some View {
        
        NavigationSplitView(columnVisibility: $columnVisibility) {
            
            List(selection: $selection) {
                Section("My Tasks") {
                    ForEach(taskGroups) { group in
                        NavigationLink(value: SideBarSelection.group(group.id)) {
                            Label(group.title, systemImage: group.symbolName)
                        }
                        // We add a context menu for quick edits right from the sidebar
                        .contextMenu {
                            Button("Delete", role: .destructive) {
                                deleteGroup(group)
                            }
                        }
                    }
                }
                                .listStyle(.sidebar)
                                .navigationTitle("My TODO Tracker App")
                                  } detail: {
                                switch selection {
                                case "homework":
                                    PlaceHolderView(title: "Homework SDGKU", icon: "books.vertical.fill")
                                    
                                case "groceries":
                                    PlaceHolderView(title: "House Groceries", icon: "house.fill")
                                    
                                case "profile":
                                    PlaceHolderView(title: "My Settings", icon: "person.crop.circle")
                                    
                                default:
                                    ContentUnavailableView(
                                        "Welcome",
                                        systemImage:"checklist.unchecked",
                                        description: Text("Select a group from the side bar to get started"))
                                }
                            }
                                  }
                                  }
                                  
                                  }
                                  }
                                  
                                  var sampleTaskGroups: [TaskGroup] = [
                                    TaskGroup(title: "Homework SDGKU", symbolName: "books.vertical.fill", tasks: [
                                        TaskItem(title: "Check Canvas", isCompleted: true),
                                        TaskItem(title: "Example", isCompleted: false),
                                    ]),
                                    TaskGroup(title: "House Groceries", symbolName: "house.fill", tasks: [
                                        TaskItem(title: "Buy milk", isCompleted: false),
                                        TaskItem(title: "Buy eggs", isCompleted: false),
                                    ])
                                  ]
                                  
                                  struct ProfileView: View {
                                var body: some View {
                                    Image(systemName: "person.crop.circle")
                                        .font(.system(size: 80))
                                        .foregroundStyle(.green)
                                    
                                    Text("Professor Gabriela")
                                        .font(.title3)
                                }
                            }

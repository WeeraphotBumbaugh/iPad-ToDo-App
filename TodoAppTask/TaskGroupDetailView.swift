//
//  TaskGroupDetailView.swift (was PlaceHolderView.swift)
//  TodoAppTask
//
//  Created by SDGKU on 01/11/25.
//

import SwiftUI

struct TaskGroupDetailView: View {
    
    @Binding var group: TaskGroup
    @FocusState private var focusedTaskID: UUID?
    
    var appAccentColor: Color
    
    private var completedTaskCount: Int {
        group.tasks.filter { $0.isCompleted }.count
    }
    
    private var completionPercentage: Double {
        if group.tasks.isEmpty {
            return 0.0
        }
        return Double(completedTaskCount) / Double(group.tasks.count)
    }
    
    private var completionText: String {
        if group.tasks.isEmpty {
            return "No tasks yet."
        }
        return "\(completedTaskCount) of \(group.tasks.count) completed"
    }
        
    var body: some View {
        NavigationStack {
            List {
                
                Section {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Completion Progress")
                            .font(.headline)
                        
                        ProgressView(value: completionPercentage)
                            .tint(group.tasks.isEmpty ? .gray : appAccentColor)
                            .animation(.snappy, value: completionPercentage)
                        
                        Text(completionText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                }

                Section {
                    ForEach($group.tasks) { $task in
                        TaskRow(task: $task, focusedTaskID: $focusedTaskID, appAccentColor: appAccentColor)
                    }
                    .onDelete(perform: deleteTask)
                } header: {
                    Text("Tasks")
                        .font(.headline)
                        .foregroundStyle(appAccentColor)
                }
            }
            .listStyle(.insetGrouped)
            .overlay {
                if group.tasks.isEmpty {
                    ContentUnavailableView(
                        "No Tasks Yet",
                        systemImage: "list.bullet.clipboard",
                        description: Text("Tap the '+' button to add your first task.")
                    )
                    .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(group.title)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing ) {
                    Button {
                        addNewTask()
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
        }
    }
    
    private func deleteTask(at offsets: IndexSet) {
        group.tasks.remove(atOffsets: offsets)
    }
    
    private func addNewTask() {
        withAnimation {
            let newTask = TaskItem(title: "", isCompleted: false)
            group.tasks.append(newTask)
            focusedTaskID = newTask.id
        }
    }
}

struct TaskRow: View {
    @Binding var task: TaskItem
    var focusedTaskID: FocusState<UUID?>.Binding
    var appAccentColor: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Button {
                withAnimation(.snappy) {
                    task.isCompleted.toggle()
                }
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(task.isCompleted ? appAccentColor : .secondary)
            }
            .buttonStyle(.plain)
            
            TextField("New Task", text: $task.title)
                .strikethrough(task.isCompleted, color: .secondary)
                .foregroundStyle(task.isCompleted ? .secondary : .primary)
                .focused(focusedTaskID, equals: task.id)
                .onSubmit {

                    focusedTaskID.wrappedValue = nil
                }
        }
        .padding(.vertical, 8)
    }
}

//
//  TaskGroupDetailView.swift (was PlaceHolderView.swift)
//  TodoAppTask
//
//  Created by Gabriela Sanchez on 01/11/25.
//

import SwiftUI

struct TaskGroupDetailView: View {
    
    @Binding var group: TaskGroup
    @FocusState private var focusedTaskID: UUID?
    
    var body: some View {
        NavigationStack {
            List {
                ForEach($group.tasks) { $task in
                    TaskRow(task: $task, focusedTaskID: $focusedTaskID)
                }
                .onDelete(perform: deleteTask)
            }
            .overlay {
                if group.tasks.isEmpty {
                    ContentUnavailableView(
                        "No Tasks",
                        systemImage: "checklist.unchecked",
                        description: Text("Tap the '+' button to add your first task.")
                    )
                }
            }
            .navigationTitle(group.title)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing ) {
                    Button {
                        addNewTask()
                    } label: {
                        Image(systemName: "plus")
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
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundStyle(task.isCompleted ? .green : .secondary)
                .onTapGesture {
                    withAnimation {
                        task.isCompleted.toggle()
                    }
                }
            
            TextField("New Task", text: $task.title)
                .strikethrough(task.isCompleted, color: .secondary)
                .foregroundStyle(task.isCompleted ? .secondary : .primary)
                .focused(focusedTaskID, equals: task.id)
                .onSubmit {
                    
                    focusedTaskID.wrappedValue = nil
                }
        }
        .padding(.vertical, 4)
    }
}

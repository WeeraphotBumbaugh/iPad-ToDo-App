//
//  TaskGroupDetailView.swift
//  TodoAppTask
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
        guard !group.tasks.isEmpty else { return 0.0 }
        return Double(completedTaskCount) / Double(group.tasks.count)
    }

    private var completionText: String {
        guard !group.tasks.isEmpty else { return String(localized: "No tasks yet.") }
        return String(localized: "\(completedTaskCount) of \(group.tasks.count) completed")
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(String(localized: "Completion Progress"))
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
                        TaskRow(task: $task,
                                focusedTaskID: $focusedTaskID,
                                appAccentColor: appAccentColor)
                    }
                    .onDelete(perform: deleteTask)
                    .onMove(perform: moveTask)
                } header: {
                    Text(String(localized: "Tasks"))
                        .font(.headline)
                        .foregroundStyle(appAccentColor)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(group.title)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) { EditButton() }
                ToolbarItem(placement: .primaryAction) {
                    Button { addNewTask() } label: {
                        Image(systemName: "plus")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(appAccentColor)
                            .padding(6)
                            .background(appAccentColor.opacity(0.15))
                            .clipShape(Circle())
                    }
                    .keyboardShortcut("n", modifiers: [.command])
                    .accessibilityLabel(Text(String(localized: "Add Task")))
                }
            }
            .overlay {
                if group.tasks.isEmpty {
                    ContentUnavailableView(
                        String(localized: "No Tasks Yet"),
                        systemImage: "list.bullet.clipboard",
                        description: Text(String(localized: "Tap the '+' button to add your first task."))
                    )
                    .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func deleteTask(at offsets: IndexSet) { group.tasks.remove(atOffsets: offsets) }
    private func moveTask(from src: IndexSet, to dst: Int) { group.tasks.move(fromOffsets: src, toOffset: dst) }

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

    @State private var showDrawing = false

    var body: some View {
        HStack(spacing: 12) {
            Button {
                withAnimation(.snappy) { task.isCompleted.toggle() }
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(task.isCompleted ? appAccentColor : .secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text(task.isCompleted
                                     ? String(localized: "Mark incomplete")
                                     : String(localized: "Mark complete")))

            VStack(alignment: .leading, spacing: 6) {
                TextField(String(localized: "New Task"), text: $task.title)
                    .strikethrough(task.isCompleted, color: .secondary)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)
                    .focused(focusedTaskID, equals: task.id)
                    .onSubmit { focusedTaskID.wrappedValue = nil }

                if let thumb = task.drawingThumbnail {
                    HStack {
                        thumb
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 48)
                            .clipped()
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(.secondary.opacity(0.3), lineWidth: 1))
                            .accessibilityLabel(Text(String(localized: "Drawing preview")))
                        Spacer()
                        Button {
                            showDrawing = true
                        } label: {
                            Label(String(localized: "Edit Drawing"), systemImage: "pencil.and.outline")
                        }
                        .buttonStyle(.borderless)
                        .keyboardShortcut("d", modifiers: [.command])
                    }
                }
            }

            Spacer()

            Button { showDrawing = true } label: {
                Image(systemName: task.hasDrawing ? "pencil.tip.crop.circle.badge.plus" : "pencil.tip.crop.circle")
                    .font(.title3)
            }
            .help(task.hasDrawing ? String(localized: "Edit drawing") : String(localized: "Add drawing"))
        }
        .padding(.vertical, 8)
        .contextMenu {
            Button { showDrawing = true } label: {
                Label(task.hasDrawing ? String(localized: "Edit Drawing") : String(localized: "Add Drawing"),
                      systemImage: "pencil.tip")
            }
            if task.hasDrawing {
                Button(role: .destructive) { task.drawingData = nil } label: {
                    Label(String(localized: "Remove Drawing"), systemImage: "trash")
                }
            }
        }
        .sheet(isPresented: $showDrawing) {
            DrawingSheet(
                initialData: task.drawingData,
                onSave: { data in task.drawingData = data }
            )
        }
    }
}

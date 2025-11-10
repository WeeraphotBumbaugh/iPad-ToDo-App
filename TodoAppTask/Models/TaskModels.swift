//
//  TaskModels.swift
//  TodoAppTask
//

import Foundation

struct TaskItem: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var isCompleted: Bool = false

    init(id: UUID = UUID(), title: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
}

struct TaskGroup: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var symbolName: String
    var tasks: [TaskItem]

    init(id: UUID = UUID(), title: String, symbolName: String, tasks: [TaskItem]) {
        self.id = id
        self.title = title
        self.symbolName = symbolName
        self.tasks = tasks
    }
}

struct MainTaskGroup: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var symbolName: String
    var taskGroupIDs: [TaskGroup.ID]

    init(id: UUID = UUID(), title: String, symbolName: String, taskGroupIDs: [TaskGroup.ID]) {
        self.id = id
        self.title = title
        self.symbolName = symbolName
        self.taskGroupIDs = taskGroupIDs
    }
}

enum SidebarSelection: Hashable {
    case group(TaskGroup.ID)
    case profile
}

struct SidebarNode: Identifiable, Hashable {
    let id: UUID
    let title: String
    let symbolName: String
    let selection: SidebarSelection
    var children: [SidebarNode]? = nil
}

enum ParentChoice: Equatable {
    case existing(MainTaskGroup.ID)               // attach to this parent
    case newParent(title: String, symbol: String) // create this parent and attach
    case auto                                     // attach to first or create default
}

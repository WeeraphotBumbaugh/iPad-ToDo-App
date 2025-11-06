//
//  TaskModels.swift
//  TodoAppTask
//
//  Created by SDGKU on 01/11/25.
//
import Foundation
struct TaskItem: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var isCompleted: Bool = false
}
struct TaskGroup: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var symbolName: String
    var tasks: [TaskItem]
}

enum SidebarSelection: Hashable {
    case group(TaskGroup.ID)
    case profile
}

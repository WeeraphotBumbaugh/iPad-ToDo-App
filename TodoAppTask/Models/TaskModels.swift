//
//  TaskModels.swift
//  TodoAppTask
//

import Foundation
import SwiftUI
import PencilKit

enum Priority: Int, Codable, Comparable, CaseIterable {
    case low = 0
    case medium = 1
    case high = 2
    
    var title: String {
        switch self {
        case .low:    return "Low"
        case .medium: return "Medium"
        case .high:   return "High"
        }
    }
    
    var color: Color {
        switch self {
        case .low:    return .gray
        case .medium: return .yellow
        case .high:   return .red
        }
    }

    static func < (lhs: Priority, rhs: Priority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

struct TaskItem: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var isCompleted: Bool = false
    var creationDate: Date
    var priority: Priority = .medium
    var drawingData: Data? = nil

    init(
        id: UUID = UUID(),
        title: String,
        isCompleted: Bool = false,
        drawingData: Data? = nil,
        creationDate: Date = Date(),
        priority: Priority = .medium
    ) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.drawingData = drawingData
        self.creationDate = creationDate
        self.priority = priority
    }
}

struct TaskGroup: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var symbolName: String
    var tasks: [TaskItem]

    init(
        id: UUID = UUID(),
        title: String,
        symbolName: String,
        tasks: [TaskItem]
    ) {
        self.id = id
        self.title = title
        self.symbolName = symbolName
        self.tasks = tasks
    }
    
    mutating func sortTasks() {
        // High → Medium → Low
        tasks.sort { $0.priority > $1.priority }
    }
}

struct MainTaskGroup: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var symbolName: String
    var taskGroupIDs: [TaskGroup.ID]

    init(
        id: UUID = UUID(),
        title: String,
        symbolName: String,
        taskGroupIDs: [TaskGroup.ID]
    ) {
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
    case existing(MainTaskGroup.ID)
    case newParent(title: String, symbol: String)
    case auto
}

struct ProfileCategory: Identifiable {
    let id = UUID()
    let name: LocalizedStringKey
    let imageName: String
    let storageKey: String
}

// MARK: - Drawing helpers for UI

extension TaskItem {
    var hasDrawing: Bool { drawingData != nil }

    var drawingThumbnail: Image? {
        guard
            let data = drawingData,
            let pk = try? PKDrawing(data: data)
        else { return nil }
        
        let bounds = pk.bounds.isEmpty
            ? CGRect(x: 0, y: 0, width: 240, height: 140)
            : pk.bounds
        
        let ui = pk.image(from: bounds, scale: 2.0)
        return Image(uiImage: ui)
    }
}

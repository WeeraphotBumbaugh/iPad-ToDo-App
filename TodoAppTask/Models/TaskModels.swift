//
//  TaskModels.swift
//  TodoAppTask
//

import Foundation
import SwiftUI
import PencilKit
import SwiftUICore

struct TaskItem: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var isCompleted: Bool = false
    var creationDate: Date

    // Store native PencilKit data for reliability
    var drawingData: Data? = nil

    init(id: UUID = UUID(), title: String, isCompleted: Bool = false, drawingData: Data? = nil, creationDate: Date = Date()) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.drawingData = drawingData
        self.creationDate = creationDate
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

struct ProfileCategory: Identifiable {
    let id = UUID()
    let name: LocalizedStringKey
    let imageName: String
    let storageKey: String
}

// MARK: - Drawing helpers for UI

extension TaskItem {
    var hasDrawing: Bool { drawingData != nil }

    // Render a thumbnail from native PK data
    var drawingThumbnail: Image? {
        guard let data = drawingData, let pk = try? PKDrawing(data: data) else { return nil }
        let bounds = pk.bounds.isEmpty ? CGRect(x: 0, y: 0, width: 240, height: 140) : pk.bounds
        let ui = pk.image(from: bounds, scale: 2.0)
        return Image(uiImage: ui)
    }
}

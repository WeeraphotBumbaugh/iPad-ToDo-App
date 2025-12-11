//
//  TaskModelTests.swift
//  TodoAppTaskTests
//
//  Created by Weeraphot Bumbaugh on 12/7/25.
//

import XCTest
@testable import TodoAppTask

final class TaskModelTests: XCTestCase {
    
    func testTaskItemDefaultPriorityIsMedium() {
        let task = TaskItem(title: "Test Title")
        XCTAssertEqual(task.priority, .medium)
    }
    
    func testSortTasksByPriority() {
        let lowTask  = TaskItem(title: "Low Priority",    priority: .low)
        let medTask  = TaskItem(title: "Medium Priority", priority: .medium)
        let highTask = TaskItem(title: "High Priority",   priority: .high)
        
        var group = TaskGroup(
            title: "Priority example",
            symbolName: "folder",
            tasks: [lowTask, medTask, highTask]
        )
        
        group.sortTasks()
        
        XCTAssertEqual(group.tasks[0].priority, .high)
        XCTAssertEqual(group.tasks[1].priority, .medium)
        XCTAssertEqual(group.tasks[2].priority, .low)
    }
    
    func testPriorityComparableOrder() {
        XCTAssertTrue(Priority.low < .medium)
        XCTAssertTrue(Priority.medium < .high)
        XCTAssertTrue(Priority.high > .low)
    }
}

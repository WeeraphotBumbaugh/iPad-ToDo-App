//
//  ToDoTests.swift
//  TodoAppTask
//
//  Created by Weeraphot Bumbaugh on 12/2/25.
//

import XCTest
@testable import TodoAppTask

final class ToDoTests: XCTestCase {
    var storeManager: StoreManager!
    override func setUpWithError() throws {
        super.setUp()
        storeManager = StoreManager()
    }
    
    override func tearDownWithError() throws {
        storeManager = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertFalse(storeManager.isPro, "User should be initially free")
    }
    
    func testGroupInitalization() {
        // when
        let task1 = TaskItem(title: "Test task")
        let task2 = TaskItem(title: "Test task 2", isCompleted: true)
        
        //given
        let group = TaskGroup(title: "Test Group 1", symbolName: "briefcase", tasks: [task1, task2])
        
        //then
        XCTAssertEqual(group.title, "Test Group 1")
        XCTAssertEqual(group.symbolName, "briefcase")
        XCTAssertEqual(group.tasks.count, 2)
        XCTAssertEqual(group.tasks.first?.title, "Test task")
        XCTAssertTrue(group.tasks.last?.isCompleted ?? false)

    }
}

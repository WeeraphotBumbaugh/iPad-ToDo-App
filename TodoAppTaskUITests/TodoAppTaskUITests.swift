//
//  TodoAppTaskUITests.swift
//  TodoAppTaskUITests
//
//  Created by Gabriela Sanchez on 01/11/25.
//

import XCTest

final class TodoAppTaskUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    func testAddGroupFlow() {
        let app = XCUIApplication()
        app.launch()
        
        let schoolButton = app.buttons["school_data"]
        XCTAssertTrue(schoolButton.waitForExistence(timeout: 5.0), "The school button should exist on the home screen")
        schoolButton.tap()
        
        let addNewGroupButton = app.buttons["addNewGroupButton"]
        XCTAssertTrue(addNewGroupButton.waitForExistence(timeout: 2.0), "Icon is present")
        addNewGroupButton.tap()
        
        let nameField = app.textFields["newGroupNameTestField"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2.0), "Text field is visible")
        nameField.tap()
        nameField.typeText("UI Test Group")
        
        let addButton = app.buttons["addNewGroupButton2"]
        addButton.tap()
        
        XCTAssertTrue(addNewGroupButton.exists, "Should return to main lit")
        
    }
    
    func testAddTaskFlow() {
        let app = XCUIApplication()
        app.launch()
        
        let schoolButton = app.buttons["school_data"]
        XCTAssertTrue(schoolButton.waitForExistence(timeout: 5.0), "The school button should exist on the home screen")
        schoolButton.tap()
        
        let addNewGroupButton = app.buttons["addNewGroupButton"]
        XCTAssertTrue(addNewGroupButton.waitForExistence(timeout: 2.0), "Icon is present")
        addNewGroupButton.tap()
        
        let nameField = app.textFields["newGroupNameTestField"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2.0), "Text field is visible")
        nameField.tap()
        nameField.typeText("UI Test Group 2")
        
        let addButton = app.buttons["addNewGroupButton2"]
        addButton.tap()
        
        let groupTitle = app.navigationBars.staticTexts["UI Test Group 2"]
        XCTAssertTrue(groupTitle.waitForExistence(timeout: 3.0), "Should be showing the detail for UI Test Group 2")

        let addTaskButton = app.buttons["addTaskButton"]
        XCTAssertTrue(addTaskButton.waitForExistence(timeout: 2.0), "The add task button should be visible")
        addTaskButton.tap()

        let taskTitleField = app.textFields["taskTitleField"]
        XCTAssertTrue(taskTitleField.waitForExistence(timeout: 2.0),"The task title field should be visible")
        taskTitleField.tap()
        taskTitleField.typeText("UI Test Task 1")
        app.keyboards.buttons["return"].tap()
        
        XCTAssertTrue(taskTitleField.waitForExistence(timeout: 2.0),"The task title field should still exist after submiting")
        
        let value = taskTitleField.value as? String
        XCTAssertEqual(value, "UI Test Task 1", "The task title field should contain the text typed")

    }
}

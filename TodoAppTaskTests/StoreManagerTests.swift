//
//  StoreManagerTests.swift
//  TodoAppTask
//
//  Created by Weeraphot Bumbaugh on 12/2/25.
//

import XCTest
@testable import TodoAppTask

final class StoreManagerTests: XCTestCase {
    var storeManager: StoreManager!
    
    
    //before state
    override func setUpWithError() throws {
        storeManager = StoreManager()
        
    }
    
    //after state
    override func tearDownWithError() throws {
        storeManager = nil
    }
    
    func testFreeUserGroupLimit() {
        XCTAssertTrue(storeManager.canAddGroup(currentGroupCount: 0))
        XCTAssertTrue(storeManager.canAddGroup(currentGroupCount: 2))
        XCTAssertFalse(storeManager.canAddGroup(currentGroupCount: 3), "Free user shouldn't be able to add 4th group")
        XCTAssertFalse(storeManager.canAddGroup(currentGroupCount: 4))
    }
    
    func testProUserGroupLimit() {
        storeManager.isPro = true
        XCTAssertTrue(storeManager.canAddGroup(currentGroupCount: 5), "Pro user can exceed the limit")
        XCTAssertTrue(storeManager.canAddGroup(currentGroupCount: 10), "Pro user can exceed the limit")
    }
}

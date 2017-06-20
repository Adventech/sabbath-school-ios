//
//  SnapshotUITests.swift
//  SnapshotUITests
//
//  Created by Heberti Almeida on 2017-06-19.
//  Copyright © 2017 Adventech. All rights reserved.
//

import XCTest
import SimulatorStatusMagic

class SnapshotUITests: XCTestCase {
    fileprivate let app = XCUIApplication()
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false

        SDStatusBarManager.sharedInstance().enableOverrides()

        setupSnapshot(app)
        app.launch()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        SDStatusBarManager.sharedInstance().disableOverrides()
    }

    func testExample() {
        app.buttons["continueWithoutLogin"].tap()
        app.buttons["loginAnonimousOptionYes"].tap()

        snapshot("01Quarterly")
        app.buttons["openLesson"].tap()
        snapshot("02Lesson")
        app.buttons["readLesson"].tap()
        snapshot("03Reading")

        app.buttons["themeSettings"].tap()
        snapshot("04Theme")
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element(boundBy: 1).tap()

        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()

        app.buttons["openSettings"].tap()
        app.tables.cells.otherElements.matching(identifier: "logOut").element.tap()
        
    }
    
}

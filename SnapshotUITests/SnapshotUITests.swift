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

    func testScreenshots() {
        app.buttons["continueWithoutLogin"].tap()
        app.buttons["loginAnonymousOptionYes"].tap()

        // Select language
        var language = locale.components(separatedBy: "-")[0]
        app.buttons["openLanguage"].tap()

        if language == "da" {
            language = "en"
        }

        if language == "no" {
            language = "en"
        }

        if language == "nb" {
            language = "en"
        }

        if language == "id" {
            language = "in"
        }

        app.tables.cells.otherElements[language].tap()

        // Quarterly
        snapshot("01Quarterly")

        // Lesson
        app.buttons["openLesson"].tap()
        snapshot("02Lesson")

        // Read
        app.tables.cells.element(boundBy: 1).tap()
        snapshot("03Reading")

        // Verse
        let verseRegex = "(?:\\d|I{1,3})?\\s?\\w{2,}\\.?\\s*\\d{1,}(:|,)\\d{1,}-?,?\\d{0,2}(?:,\\d{0,2}){0,2}"
        let verses = app.collectionViews.webViews.staticTexts.matching(NSPredicate(format: "label MATCHES %@", verseRegex))

        if verses.count > 0 {
            verses.element(boundBy: 0).forceTapElement()
            snapshot("04Verse")
            app.buttons["dismissBibleVerse"].tap()
            app.collectionViews.webViews.element.swipeDown()
            app.statusBars.element.tap()
        }

        // Theme
        app.buttons["themeSettings"].tap()
        snapshot("05Theme")
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element(boundBy: 1).tap()

        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()

        app.buttons["openSettings"].tap()
        app.tables.cells.otherElements.matching(identifier: "logOut").element.tap()
    }
}

extension XCUIElement {
    func forceTapElement() {
        if isHittable {
            tap()
        } else {
            XCUIApplication().collectionViews.webViews.element.swipeUp()
            forceTapElement()
        }
    }
}

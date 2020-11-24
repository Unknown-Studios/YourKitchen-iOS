//
//  Snapshots.swift
//  Snapshots
//
//  Created by Markus Moltke on 08/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import XCTest

class Snapshots: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try super.tearDownWithError()
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication(bundleIdentifier: "com.unknown-studios.YourKitchen")
        app.launchArguments = ["-uiTesting", "SKIP_ANIMATIONS"]
        setupSnapshot(app, waitForAnimations: false)
        app.launch()

        sleep(4)
        
        let tabBarsQuery = app.tabBars
        snapshot("01Recipes")
        tabBarsQuery.buttons.element(boundBy: 1).tap()
        snapshot("02Explore")
        tabBarsQuery.buttons.element(boundBy: 2).tap()
        snapshot("03Refrigerator")
        sleep(1)
        tabBarsQuery.buttons.element(boundBy: 3).tap()
        snapshot("04Mealplan")
        tabBarsQuery.buttons.element(boundBy: 4).tap()
        snapshot("05Profile")

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
}

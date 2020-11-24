//
//  SnapshotsTV.swift
//  SnapshotsTV
//
//  Created by Markus Moltke on 24/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import XCTest

class SnapshotsTV: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication(bundleIdentifier: "com.unknown-studios.YourKitchenTV")
        app.launchArguments = ["-uiTesting"]
        setupSnapshot(app)
        app.launch()

        sleep(4)
        let remote = XCUIRemote.shared

        snapshot("01Explore")
        remote.press(.right)
        sleep(1)
        snapshot("02Mealplan")
        remote.press(.right)
        sleep(1)
        snapshot("03Settings")
    }
}

//
//  SwiftDataUnitTestsUITests.swift
//  SwiftDataUnitTestsUITests
//
//  Created by Azizbek Asadov on 12/03/24.
//

import XCTest
@testable import SwiftDataUnitTests

@MainActor final class SwiftDataUnitTestsUITests: XCTestCase {
    var app: XCUIApplication!
    
    func test_appStartsEmpty() {
        XCTAssertEqual(app.cells.count, 0, "There should be 0 movies when the app is first launched.")
    }
    
    func test_createSamples() {
        app.buttons["Add Samples"].tap()
        
        XCTAssertEqual(app.cells.count, 3, "There should be 3 movies after adding sample data.")
    }
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments =  ["enable-testing"]
        app.launch()
    }
    
}


//If you have multiple checks inside a single predicate that you know will either be evaluated often or has lots of data to filter, you should arrange them in a smart order:
//
//If you can, place the most restrictive checks first to eliminate data as quickly as possible.
//Run faster checks earlier, such as preferring integer comparison to a string comparison.

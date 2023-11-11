//
//  PaletteSwipeTests.swift
//  PaletteSwipeTests
//
//  Created by Marina McPeak on 2023-11-02.
//

import XCTest
@testable import PaletteSwipe
import SwiftUI

final class PaletteSwipeTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testTopRowSwipeRight() throws {
        // Arrange
        let viewModel = PuzzleViewModel()
        let expectedGrid = [
            [Color.yellow, Color.blue, Color.blue],
            [Color.blue, Color.blue, Color.blue],
            [Color.blue, Color.blue, Color.blue]
        ]
        let expectedLeftOverflow = [Color.red, Color.yellow, Color.yellow]
        let expectedRightOverflow = [Color.blue, Color.red, Color.red]

        // Act
        viewModel.swipe(atRow: 0, column: 0, direction: .right)

        // Assert
        XCTAssertEqual(viewModel.gridColors, expectedGrid)
        XCTAssertEqual(viewModel.leftOverflow, expectedLeftOverflow)
        XCTAssertEqual(viewModel.rightOverflow, expectedRightOverflow)
    }



}

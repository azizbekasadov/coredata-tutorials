//
//  SwiftDataUnitTestsTests.swift
//  SwiftDataUnitTestsTests
//
//  Created by Azizbek Asadov on 12/03/24.
//

import XCTest
import SwiftData
@testable import SwiftDataUnitTests

@MainActor final class SwiftDataUnitTestsTests: XCTestCase {

    func testAppStartsEmpty() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Movie.self, configurations: config)

        let sut = ContentView.ViewModel(modelContext: container.mainContext)

        XCTAssertEqual(sut.movies.count, 0, "There should be 0 movies when the app is first launched.")
    }
    
    func test_creatingSamples() throws {
        // given
        let sut = try make(viewModel: ContentView.ViewModel.self)
        //when
        sut.addSamples()
        // then
        XCTAssertEqual(sut.movies.count, 3, "There should be exactly 3 movies after adding samples")
    }
    
    func test_clearingSamples() throws {
        // given
        let sut = try make(viewModel: ContentView.ViewModel.self)
        //when
        sut.clear()
        // then
        XCTAssertEqual(sut.movies.count, 0, "There should be exactly 3 movies after adding samples")
    }
    
    private func make<T: ViewModelTestable>(viewModel: T.Type) throws -> T {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Movie.self, configurations: config)
        return T(modelContext: container.mainContext)
    }
}

protocol ViewModelTestable {
    init(modelContext: ModelContext)
}

extension ContentView.ViewModel: ViewModelTestable { }

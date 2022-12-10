//
//  FavoritesUseCaseTests.swift
//  SensorReaderTests
//
//  Created by Vid Tadel on 12/10/22.
//

@testable import SensorReader
import XCTest

final class FavoritesUseCaseTests: XCTestCase {

    private var useCase: FavoritesUseCase<MockPersistenceStore<[FavoriteModel]>>!
    private var mockStore: MockPersistenceStore<[FavoriteModel]>!

    override func setUpWithError() throws {
        mockStore = MockPersistenceStore<[FavoriteModel]>()
        useCase = FavoritesUseCase(store: mockStore)
    }

    func test_startsEmpty() {
        XCTAssertTrue(useCase.favorites.value.isEmpty)
    }

    func test_loadsContentFromStore() {
        let exp = expectation(description: "fetch called")
        let mockFavs: [FavoriteModel] = [.init(id: "1")]
        mockStore.fetchCall = {
            exp.fulfill()
            return mockFavs
        }
        useCase = FavoritesUseCase(store: mockStore)
        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(useCase.favorites.value, mockFavs)
    }

    func test_StoresNewValue() {
        let exp = expectation(description: "store called")
        mockStore.storeCall = { content in
            XCTAssertEqual(content, [.init(id: "1")])
            exp.fulfill()
        }
        useCase.favorites.send([.init(id: "1")])
        waitForExpectations(timeout: 0.1)
    }
}

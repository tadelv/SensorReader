//
//  FavoritesUseCaseTests.swift
//  SensorReaderTests
//
//  Created by Vid Tadel on 12/10/22.
//

import Combine
@testable import SensorReader
import XCTest

final class FavoritesUseCaseTests: XCTestCase {

    private var useCase: FavoritesUseCase<MockPersistenceStore<[FavoriteModel]>>!
    private var mockStore: MockPersistenceStore<[FavoriteModel]>!

    override func setUpWithError() throws {
        mockStore = MockPersistenceStore<[FavoriteModel]>()
        useCase = FavoritesUseCase(store: mockStore)
    }

    func test_loadsContentFromStore() {
        let exp = expectation(description: "calls fetch on store")
        let mockFavs: [FavoriteModel] = [.init(id: "1")]
        mockStore.fetchCall = {
            exp.fulfill()
            return mockFavs
        }
        useCase = FavoritesUseCase(store: mockStore)
        let elements = useCase.favorites.record(numberOfRecords: 2).waitAndCollectRecords(timeout: 0.4)

        XCTAssertRecordedValues(elements, [[], mockFavs])
        wait(for: [exp], timeout: 0.1)
    }

    func test_StoresNewValue() throws {
        let recorder = useCase.favorites.record(numberOfRecords: 3)
        let exp = expectation(description: "store called")
        mockStore.storeCall = { content in
            XCTAssertEqual(content, [.init(id: "1")])
            exp.fulfill()
        }
        Task {
            try await useCase.add(.init(id: "1"))
        }
        let records = recorder.waitAndCollectRecords(timeout: 0.4)
        waitForExpectations(timeout: 0.1)

        XCTAssertRecordedValues(records, [[], [], [.init(id: "1")]])
    }

    func test_RemovesValue() throws {
        let exp = expectation(description: "remove called")
        mockStore.storeCall = { content in
            XCTAssertTrue(content?.isEmpty ?? false)
            exp.fulfill()
        }
        mockStore.fetchCall = {
            [.init(id: "1")]
        }
        useCase = FavoritesUseCase(store: mockStore)
        let recorder = useCase.favorites.record(numberOfRecords: 3)

        Task {
            try await useCase.remove(.init(id: "1"))
        }
        let records = recorder.waitAndCollectRecords(timeout: 0.4)
        wait(for: [exp], timeout: 0.1)

        XCTAssertRecordedValues(records, [[], [.init(id: "1")], []])
    }

    func test_recoversAfterFailure() {
        enum TestError: Error {
            case test
        }
        var cancellables = Set<AnyCancellable>()
        let exp1 = expectation(description: "fails first time")

        mockStore.fetchCall = {
            throw TestError.test
        }
        useCase = FavoritesUseCase(store: mockStore)

        useCase.favorites.dropFirst().sink { _ in
            exp1.fulfill()
        } receiveValue: {
            XCTFail("unexpected value: \($0)")
        }.store(in: &cancellables)
        waitForExpectations(timeout: 0.1)

        mockStore.fetchCall = {
            [.init(id: "1")]
        }

        let exp2 = expectation(description: "receives value")
        useCase.favorites.dropFirst().sink {
            XCTFail("unexpected completion: \($0)")
        } receiveValue: {
            XCTAssertEqual($0, [.init(id: "1")])
            exp2.fulfill()
        }.store(in: &cancellables)
        waitForExpectations(timeout: 0.1)
        withExtendedLifetime(cancellables) {}
    }
}

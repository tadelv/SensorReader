//
//  ReadingsUseCaseTests.swift
//  SensorReaderTests
//
//  Created by Vid Tadel on 12/8/22.
//

import Combine
@testable import SensorReader
import XCTest

final class ReadingsUseCaseTests: XCTestCase {

    var useCase: ReadingsUseCase!
    var mockProvider: MockProvider!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        mockProvider = MockProvider()
        useCase = ReadingsUseCase(reader: mockProvider, refreshInterval: 0.5)

        let testReadings: [MockProvider.MockReading] = [
            .init(name: "Test",
                  value: "1",
                  unit: "A")
        ]
        mockProvider.mockReadings = testReadings
    }

    func test_requestsDataOnSubscription() {
        let exp = expectation(description: "gets value")
        let cancellable = useCase.readings.sink {
            XCTFail("received unexpected completion: \($0)")
        } receiveValue: { readings in
            XCTAssertTrue(Thread.isMainThread)
            XCTAssertEqual(readings.count, 1, "got: \(readings)")
            exp.fulfill()
        }

        waitForExpectations(timeout: 0.1)
        withExtendedLifetime(cancellable) {
            
        }
    }

    func test_schedulesTimer() {
        let exp = expectation(description: "value refreshes twice")
        exp.expectedFulfillmentCount = 2
        let cancellable = useCase.readings.sink {
            XCTFail("received unexpected completion: \($0)")
        } receiveValue: { _ in
            exp.fulfill()
        }
        waitForExpectations(timeout: 1.0)
        withExtendedLifetime(cancellable) {

        }
        XCTAssertEqual(mockProvider.callCount, 2)
    }

    func test_stopsTimer() {
        let cancellable = useCase.readings.sink { _ in

        } receiveValue: { _ in

        }
        let exp = expectation(description: "Waiting")

        _ = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { _ in
            exp.fulfill()
        }
        cancellable.cancel()
        waitForExpectations(timeout: 0.7)
        XCTAssertEqual(mockProvider.callCount, 1)
    }

    func test_stopsTimerOnError() {
        enum TestError: Error {
            case test
        }
        mockProvider.readingsResult = {
            throw TestError.test
        }

        let cancellable = useCase.readings.sink { _ in

        } receiveValue: { _ in

        }
        let exp = expectation(description: "Waiting")

        _ = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { _ in
            exp.fulfill()
        }

        waitForExpectations(timeout: 0.7)
        withExtendedLifetime(cancellable) {}
        XCTAssertEqual(mockProvider.callCount, 1)
    }

    func test_restartsOnResubscribe() {
        let exp1 = expectation(description: "gets 1 input")

        let waitExp = expectation(description: "Waiting")
        var cancellable = useCase.readings.sink {
            XCTFail("unexpected completion \($0)")
        } receiveValue: { _ in
            exp1.fulfill()
        }
        _ = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false) { _ in
            waitExp.fulfill()
        }
        wait(for: [exp1], timeout: 0.1)
        cancellable.cancel()
        waitForExpectations(timeout: 0.8)

        let exp2 = expectation(description: "gets second input")
        cancellable = useCase.readings.sink(receiveCompletion: {
            XCTFail("unexpected completion \($0)")
        }, receiveValue: { _ in
            exp2.fulfill()
        })

        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(mockProvider.callCount, 2)
    }
}

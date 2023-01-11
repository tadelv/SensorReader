//
//  ReadingsUseCaseTests.swift
//  SensorReaderTests
//
//  Created by Vid Tadel on 12/8/22.
//

import Combine
import CombineSchedulers
@testable import SensorReader
import XCTest

@MainActor
final class ReadingsUseCaseTests: XCTestCase {
    enum TestError: Error {
        case test
    }

    var useCase: ReadingsUseCase!
    var mockProvider: MockReadingsProvider!
    var testScheduler: TestSchedulerOf<DispatchQueue>!

    override func setUpWithError() throws {
        testScheduler = DispatchQueue.test
        mockProvider = MockReadingsProvider()
        useCase = ReadingsUseCase(reader: mockProvider,
                                  scheduler: testScheduler.eraseToAnyScheduler())

        let testReadings: [MockReadingsProvider.MockReading] = [
            .init(name: "Test",
                  value: "1",
                  unit: "A")
        ]
        mockProvider.mockReadings = testReadings
    }

    func test_requestsDataOnSubscription() async{
        let cancellable = useCase.readings.sink {
            XCTFail("received unexpected completion: \($0)")
        } receiveValue: { readings in
            XCTAssertEqual(readings.count, 1, "got: \(readings)")
        }
        await testScheduler.advance(by: 1)
        XCTAssertEqual(mockProvider.callCount, 1)
        withExtendedLifetime(cancellable) {}
    }

    func test_schedulesTimer() async {

        let cancellable = useCase.readings.sink {
            XCTFail("received unexpected completion: \($0)")
        } receiveValue: { _ in }
        await testScheduler.advance(by: .seconds(5))
        XCTAssertEqual(mockProvider.callCount, 2)
        withExtendedLifetime(cancellable) {}
    }

    func test_stopsTimer() async {
        let cancellable = useCase.readings.sink { _ in

        } receiveValue: { _ in

        }

        await testScheduler.advance(by: 1)
        cancellable.cancel()
        await testScheduler.advance(by: 4)
        XCTAssertEqual(mockProvider.callCount, 1)
    }

    func test_stopsTimerOnError() async {
        mockProvider.readingsResult = {
            throw TestError.test
        }

        let cancellable = useCase.readings.sink { _ in

        } receiveValue: { _ in

        }
        await testScheduler.advance(by: 5)
        withExtendedLifetime(cancellable) {}
        XCTAssertEqual(mockProvider.callCount, 1)
    }

    func test_restartsOnResubscribe() async {
        var cancellable = useCase.readings.sink {
            XCTFail("unexpected completion \($0)")
        } receiveValue: { _ in }
        await testScheduler.advance(by: 1)
        cancellable.cancel()
        await testScheduler.advance(by: 5)

        cancellable = useCase.readings.sink {
            XCTFail("unexpected completion \($0)")
        } receiveValue: { _ in }
        await testScheduler.advance(by: 1)
        XCTAssertEqual(mockProvider.callCount, 2)
    }

    func test_reloadsIfFetchFailsOnceAndResubscribed() async {
        mockProvider.readingsResult = {
            throw TestError.test
        }
        let exp = expectation(description: "failure event")
        let cancellable = useCase.readings.sink {
            guard case .failure(let error) = $0,
            let err = error as? TestError else {
                XCTFail("invalid completion: \($0)")
                return
            }
            XCTAssertEqual(err, TestError.test)
            exp.fulfill()
        } receiveValue: {
            XCTFail("unexpected value: \($0)")
        }
        await testScheduler.advance(by: 1)
        wait(for: [exp], timeout: 0.1)


        mockProvider.readingsResult = {
            [.init(name: "a", value: "1", unit: "1")]
        }

        let exp2 = expectation(description: "receives value")
        let cancellable2 = useCase.readings.sink {
            XCTFail("unexpected completion: \($0)")
        } receiveValue: {
            guard let element = $0.first else {
                XCTFail("elements should not be empty: \($0)")
                return
            }
            XCTAssertEqual(element.name, "a")
            XCTAssertEqual(element.value, "1")
            XCTAssertEqual(element.unit, "1")
            exp2.fulfill()
        }
        await testScheduler.advance(by: 1)
        waitForExpectations(timeout: 0.1)
        withExtendedLifetime([cancellable, cancellable2]) {}
        XCTAssertEqual(mockProvider.callCount, 2)
    }
}

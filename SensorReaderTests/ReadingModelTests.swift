//
//  ReadingModelTests.swift
//  SensorReaderTests
//
//  Created by Vid Tadel on 12/29/22.
//

@testable import SensorReader
import XCTest

final class ReadingModelTests: XCTestCase {

    func testTruncatesValue() {
        let sut = "0.12345".truncated()
        XCTAssertEqual(sut, "0.12")
        let sut1 = "20.009320390148204".truncated()
        XCTAssertEqual(sut1, "20.01")
        let sut2 = "20.009320390148204C".truncated()
        XCTAssertEqual(sut2, "20.01C")
        let sut3 = "1Yes/No".truncated()
        XCTAssertEqual(sut3, "1Yes/No")
    }
}

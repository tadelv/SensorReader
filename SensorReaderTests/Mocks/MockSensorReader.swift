//
//  MockSensorReader.swift
//  SensorReaderTests
//
//  Created by Vid Tadel on 12/8/22.
//

import Foundation
import SensorReaderKit
@testable import SensorReader

class MockProvider: SensorReadingsProvider {
    struct MockReading: SensorReading {
        var sensorClass: String { "Class" }
        var name: String
        var value: String
        var unit: String
        var updateTime: Date { Date() }
    }

    lazy var readingsResult: () throws -> [MockReading] = {
        self.mockReadings
    }

    private(set) var callCount = 0

    var mockReadings: [MockReading] = [
        MockReading(name: "Temperature",
                    value: "20",
                    unit: "C"),
        MockReading(name: "Temperature1",
                    value: "21",
                    unit: "C"),
        MockReading(name: "Temperature2",
                    value: "20",
                    unit: "C"),
        MockReading(name: "Temperature3",
                    value: "20",
                    unit: "C"),
        MockReading(name: "Temperature4",
                    value: "20",
                    unit: "C"),
        MockReading(name: "Temperature5",
                    value: "20",
                    unit: "C"),
        MockReading(name: "Temperature6",
                    value: "20",
                    unit: "C"),
        MockReading(name: "Temperature7",
                    value: "20",
                    unit: "C"),
        MockReading(name: "Temperature8",
                    value: "20",
                    unit: "C")
    ]

    func readings() async throws -> [MockReading] {
        callCount += 1
        return try readingsResult()
    }
}

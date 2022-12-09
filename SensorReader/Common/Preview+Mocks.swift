//
//  Preview+Mocks.swift
//  SensorReader
//
//  Created by Vid Tadel on 12/9/22.
//

import Combine
import SwiftUI

struct MockProvider: ReadingProviding {
    var readings: AnyPublisher<[any Reading], Error> {
        mockReadings
            .eraseToAnyPublisher()
    }

    struct MockReading: Reading {
        var device: String { "Mock Reading" }

        var name: String

        var value: String

        var unit: String

        var id: String {
            device + name + unit
        }


    }

    var mockReadings: CurrentValueSubject<[any Reading], Error> = .init([
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
    ])
}

extension PreviewProvider {
    static var mockReadingsProvider: ReadingProviding {
        MockProvider()
    }
}

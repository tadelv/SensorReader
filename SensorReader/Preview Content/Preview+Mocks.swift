//
//  Preview+Mocks.swift
//  SensorReader
//
//  Created by Vid Tadel on 12/9/22.
//

import Combine
import SwiftUI

struct MockProvider: ReadingProviding {
    struct MockReading: Reading {
        var id: String {
            device + name + unit
        }
        var device: String { "Mock Reading" }
        var name: String
        var value: String
        var unit: String
    }

    var readings: AnyPublisher<[any Reading], Error> {
        mockReadings
            .eraseToAnyPublisher()
    }

    var mockReadings: CurrentValueSubject<[any Reading], Error> = .init([
        MockReading(name: "Temperature",
                    value: "20.00937819237",
                    unit: "C"),
        MockReading(name: "CPU Usage",
                    value: "0.123534",
                    unit: "%"),
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

    fileprivate init() {}
}

struct MockFavoriteProvider: FavoritesProviding {
    let favoritesSubject: CurrentValueSubject<[FavoriteModel], Error>

    var favorites: AnyPublisher<[FavoriteModel], Error> {
        favoritesSubject.eraseToAnyPublisher()
    }

    fileprivate init() {
        let mocks = MockProvider().mockReadings.value[0...3]
        favoritesSubject = CurrentValueSubject(mocks.map { .init(id: $0.id) })
    }

    var addCall: (MockFavoriteProvider, FavoriteModel) throws -> Void = {
        $0.favoritesSubject.send($0.favoritesSubject.value + [$1])
    }

    func add(_ favorite: FavoriteModel) async throws {
        try addCall(self, favorite)
    }

    var removeCall: (MockFavoriteProvider, FavoriteModel) throws -> Void = { _, _ in

    }
    func remove(_ favorite: FavoriteModel) async throws {

    }
}

extension PreviewProvider {
    static var mockReadingsProvider: ReadingProviding {
        MockProvider()
    }

    static var mockFavoritesProvider: FavoritesProviding {
        MockFavoriteProvider()
    }
}

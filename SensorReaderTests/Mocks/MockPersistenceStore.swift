//
//  MockPersistenceStore.swift
//  SensorReaderTests
//
//  Created by Vid Tadel on 12/10/22.
//

@testable import SensorReader
import Foundation

class MockPersistenceStore<Content>: PersistenceProviding {
    var storage: Content?

    lazy var storeCall: (Content?) throws -> Void = {
        self.storage = $0
    }

    lazy var fetchCall: () throws -> Content? = {
        self.storage
    }

    func store(_ value: Content?) throws {
        try storeCall(value)
    }

    func fetch() async throws -> Content? {
        try fetchCall()
    }
}

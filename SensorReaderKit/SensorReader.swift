//
//  SensorReader.swift
//  SensorReaderKit
//
//  Created by Vid Tadel on 12/4/22.
//

import Foundation

public protocol NetworkRequestProviding {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: NetworkRequestProviding {}

open class SensorReader {
    let provider: NetworkRequestProviding
    let url: URL

    public init(_ provider: NetworkRequestProviding = URLSession.shared,
                url: URL) {
        self.provider = provider
        self.url = url
    }

    open func readings() async throws -> [some SensorReading] {
        let request = URLRequest(url: url)
        let response = try await provider.data(for: request)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return try decoder.decode([SensorReadingImpl].self, from: response.0)
    }
}

public protocol SensorReading {
    var sensorClass: String { get }
    var name: String { get }
    var value: String { get }
    var unit: String { get }
    var updateTime: Date { get }
}

struct SensorReadingImpl: Codable, SensorReading {
    enum CodingKeys: String, CodingKey {
        case sensorClass = "SensorClass"
        case name = "SensorName"
        case value = "SensorValue"
        case unit = "SensorUnit"
        case updateTime = "SensorUpdateTime"
    }
    public let sensorClass: String
    public let name: String
    public let value: String
    public let unit: String
    public let updateTime: Date
}

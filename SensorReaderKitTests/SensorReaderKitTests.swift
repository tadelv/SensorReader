//
//  SensorReaderKitTests.swift
//  SensorReaderKitTests
//
//  Created by Vid Tadel on 12/4/22.
//

import XCTest
@testable import SensorReaderKit

struct MockProvider: NetworkRequestProviding {
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        let testBundle = Bundle(for: SensorReaderKitTests.self)
        guard let filePath = testBundle.path(forResource: "data", ofType: "json")
          else { fatalError() }
        let data = try NSData(contentsOfFile: filePath) as Data
        let response = URLResponse()
        return (data, response)
    }
}

final class SensorReaderKitTests: XCTestCase {

    func testCodingConformance() throws {
        let testBundle = Bundle(for: type(of: self))
        guard let filePath = testBundle.path(forResource: "data", ofType: "json")
          else { fatalError() }
        let data = try NSData(contentsOfFile: filePath) as Data
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        let readings = try decoder.decode([SensorReadingImpl].self, from: data)
        XCTAssert(readings.isEmpty == false)
    }


    func testConnectivity() async throws {
        let client = SensorReader(MockProvider(),
                                  url: URL(fileURLWithPath: "/"))
        let readings = try await client.readings()
        XCTAssert(readings.isEmpty == false)
        print(readings.filter { $0.unit.contains("C") })
    }
}

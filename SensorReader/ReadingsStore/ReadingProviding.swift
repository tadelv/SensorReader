//
//  ReadingProviding.swift
//  SensorReader
//
//  Created by Vid Tadel on 12/8/22.
//

import Combine
import Foundation

// MARK: Protocols
protocol Reading: Identifiable where ID == String {
    var device: String { get }
    var name: String { get }
    var value: String { get }
    var unit: String { get }
}

protocol ReadingProviding {
    var readings: AnyPublisher<[any Reading], Error> { get }
}

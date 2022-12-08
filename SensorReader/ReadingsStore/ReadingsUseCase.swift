//
//  ReadingsUseCase.swift
//  SensorReader
//
//  Created by Vid Tadel on 12/8/22.
//

import Combine
import SensorReaderKit

// MARK: DI for ReadingsUseCase
protocol SensorReadingsProvider {
    associatedtype Reading: SensorReading
    func readings() async throws -> [Reading]
}

extension SensorReader: SensorReadingsProvider {}

// MARK: - UseCase implementation
final class ReadingsUseCase: ReadingProviding {
    private let reader: any SensorReadingsProvider
    private let refreshInterval: Double
    private let readingsSubject = PassthroughSubject<[any Reading], Error>()
    private var subjects: [any Subscription] = []
    private var timer: Timer?

    lazy var readings: AnyPublisher<[any Reading], Error> = {
        readingsSubject.handleEvents(receiveSubscription: { [unowned self] sub in
            self.subscriptionReceived(sub)
        }, receiveCancel: { [unowned self] in
            self.subscriptionRemoved()
        })
        .eraseToAnyPublisher()
    }()

    init(reader: any SensorReadingsProvider, refreshInterval: Double = 5.0) {
        self.reader = reader
        self.refreshInterval = refreshInterval
    }

    private func subscriptionReceived(_ sub: any Subscription) {
        subjects.append(sub)
        if timer == nil {
            timer = .scheduledTimer(withTimeInterval: refreshInterval, repeats: true, block: { [weak self] _ in
                self?.timerFired()
            })
            timerFired()
        }
    }

    private func subscriptionRemoved() {
        _ = subjects.popLast()
        if subjects.isEmpty {
            timer?.invalidate()
            timer = nil
        }
    }

    private func timerFired() {
        Task { [weak self] in
            guard let self = self else {
                return
            }
            do {
                let readings = try await self.reader.readings().map(ReadingImpl.init(from:))
                self.readingsSubject.send(readings)
            } catch {
                self.readingsSubject.send(completion: .failure(error))
            }
        }
    }
}

extension ReadingsUseCase {
    // MARK: Private data struct
    private struct ReadingImpl: Reading {
        var id: String {
            device + name + unit
        }

        var device: String
        var name: String
        var value: String
        var unit: String

        init(from reading: SensorReading) {
            self.device = reading.sensorClass
            self.name = reading.name
            self.value = reading.value
            self.unit = reading.unit
        }
    }
}

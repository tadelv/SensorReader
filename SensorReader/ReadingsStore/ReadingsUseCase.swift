//
//  ReadingsUseCase.swift
//  SensorReader
//
//  Created by Vid Tadel on 12/8/22.
//

import Combine
import CombineSchedulers
import SensorReaderKit

// MARK: DI for ReadingsUseCase
protocol SensorReadingsProvider {
    func readings() async throws -> [any SensorReading]
}

extension SensorReader: SensorReadingsProvider {}

// MARK: - UseCase implementation
final class ReadingsUseCase: ReadingProviding {
    var reader: any SensorReadingsProvider
    private let refreshInterval: Double
    private let scheduler: AnySchedulerOf<DispatchQueue>
    private var readingsSubject = PassthroughSubject<[any Reading], Error>()
    private var subjects: [any Subscription] = []
    private var schedulerConnection: Cancellable?

    lazy private(set) var readings: AnyPublisher<[any Reading], Error> = {
        readingsSubject.handleEvents(receiveSubscription: { [unowned self] sub in
            DispatchQueue.main.async {
                self.subscriptionReceived(sub)
            }
        }, receiveCancel: { [unowned self] in
            DispatchQueue.main.async {
                self.subscriptionRemoved()
            }
        })
        .eraseToAnyPublisher()
    }()

    init(reader: any SensorReadingsProvider,
         refreshInterval: Double = 5.0,
         scheduler: AnySchedulerOf<DispatchQueue>) {
        self.reader = reader
        self.refreshInterval = refreshInterval
        self.scheduler = scheduler
    }

    private func subscriptionReceived(_ sub: any Subscription) {
        subjects.append(sub)
        if schedulerConnection == nil {
//            schedulerConnection = scheduler.timerPublisher(every: .seconds(refreshInterval))
//                .autoconnect()
//                .sink { [weak self] _ in
//                    self?.timerFired()
//                }
//            timerFired()
            schedulerConnection = scheduler.schedule(after: scheduler.now,
                               interval: .seconds(_: refreshInterval),
                               tolerance: .zero) { [weak self] in
                self?.timerFired()
            }
        }
    }

    private func subscriptionRemoved() {
        _ = subjects.popLast()
        if subjects.isEmpty {
            stopTimer()
        }
    }

    private func timerFired() {
        Task { [weak self] in
            guard let self = self else {
                return
            }
            do {
                let readings = try await self.reader
                    .readings()
                    .map(ReadingImpl.init(from:))
                self.readingsSubject.send(readings)
            } catch {
                stopTimer()
                self.subjects = []
                self.readingsSubject.send(completion: .failure(error))
                self.resetPublisher()
            }
        }
    }

    private func stopTimer() {
        schedulerConnection?.cancel()
        schedulerConnection = nil
    }

    private func resetPublisher() {
        readingsSubject = .init()
        readings = readingsSubject.handleEvents(receiveSubscription: { [unowned self] sub in
            self.subscriptionReceived(sub)
        }, receiveCancel: { [unowned self] in
            self.subscriptionRemoved()
        })
        .eraseToAnyPublisher()
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

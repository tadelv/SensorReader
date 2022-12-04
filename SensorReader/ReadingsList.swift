//
//  ReadingsList.swift
//  SensorReader
//
//  Created by Vid Tadel on 12/4/22.
//

import SwiftUI
import SensorReaderKit

protocol ReadingsProvider {
    associatedtype Reading: SensorReading
    func readings() async throws -> [Reading]
}

extension SensorReader: ReadingsProvider {}

struct ReadingsList: View {
    @ObservedObject private var viewModel: ViewModel

    init(provider: any ReadingsProvider) {
        _viewModel = ObservedObject(initialValue: ViewModel(provider: provider))
    }

    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach(viewModel.readings) { reading in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(reading.device)
                                    .font(.headline)
                                Text(reading.name)
                            }
                            Spacer()
                            Text(reading.value)
                                .font(.caption)
                            Text(reading.unit)
                                .font(.caption)
                        }
                    }
                }
                if case .loading = viewModel.state {
                    Text("Loading")
                }
            }
            .toolbar {
                Button("Refresh") {
                    Task {
                        await viewModel.load()
                    }
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.load()
            }
        }
    }
}

extension ReadingsList {
    struct ReadingModel: Identifiable {
        var id: String {
            device + name + unit
        }
        let device: String
        let name: String
        let value: String
        let unit: String
    }

    @MainActor
    class ViewModel: ObservableObject {
        enum State {
            case idle
            case loading
            case error(Error)
        }

        @Published var state: State = .idle

        @Published var readings: [ReadingModel] = []

        let provider: any ReadingsProvider

        init(provider: any ReadingsProvider) {
            self.provider = provider
        }

        func load() async {
            state = .loading
            do {
                let data = try await provider.readings()
                readings = data.map {
                    .init(device: $0.sensorClass,
                          name: $0.name,
                          value: $0.value,
                          unit: $0.unit)
                }
                state = .idle
            } catch {
                state = .error(error)
            }
        }
    }
}

struct ReadingsList_Previews: PreviewProvider {
    struct MockProvider: ReadingsProvider {
        struct MockReading: SensorReading {
            var sensorClass: String { "Class" }
            var name: String
            var value: String
            var unit: String
            var updateTime: Date { Date() }
        }
        func readings() async throws -> [MockReading] {
            sleep(1)
            return [
                MockReading(name: "Temperature",
                            value: "20",
                            unit: "C")
            ]
        }
    }
    static var previews: some View {
        ReadingsList(provider: MockProvider())
    }
}

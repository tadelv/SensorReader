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
                VStack {
                    ProgressView()
                    Text("Loading")
                        .background(Color(UIColor.systemBackground))
                }
            }
            if case .error(let err) = viewModel.state {
                let message = "Failed with: \(err.localizedDescription)"
                Text(message)
                    .background(Color(UIColor.systemBackground))
            }
        }
        .onAppear {
            refresh()
        }
        .toolbar {
            Button {
                refresh()
            } label: {
                Image(systemName: "arrow.clockwise")
            }

        }
        .navigationTitle("List")
    }

    func refresh() {
        Task {
            await viewModel.load()
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
        }
    }
    static var previews: some View {
        ReadingsList(provider: MockProvider())
    }
}

//
//  ReadingsList.swift
//  SensorReader
//
//  Created by Vid Tadel on 12/4/22.
//

import Combine
import SwiftUI
import SensorReaderKit


struct ReadingsList: View {
    @ObservedObject private var viewModel: ReadingsListViewModel

    init(viewModel: ReadingsListViewModel) {
        _viewModel = ObservedObject(initialValue: viewModel)
    }

    var body: some View {
        ZStack {
            List {
                ForEach(viewModel.readings) { reading in
                    HStack {
                        Text(reading.name)
                        Spacer()
                        Text(reading.value)
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

}

struct ReadingsList_Previews: PreviewProvider {
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
    static var previews: some View {
        ReadingsList(viewModel: ReadingsListViewModel(provider: MockProvider()))
    }
}

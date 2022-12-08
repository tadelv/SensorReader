//
//  DashboardView.swift
//  SensorReader
//
//  Created by Vid Tadel on 12/4/22.
//

import Combine
import SensorReaderKit
import SwiftUI

struct FavoriteModel {
    let id: String
}

protocol FavoritesProvider {
    var favorites: CurrentValueSubject<[FavoriteModel], Error> { get }
}

struct DashboardView: View {
    @ObservedObject private var viewModel: ViewModel

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    init(SensorReadingsProvider: any SensorReadingsProvider,
         favoritesProvider: any FavoritesProvider) {
        _viewModel = ObservedObject(initialValue: ViewModel(SensorReadingsProvider: SensorReadingsProvider,
                                                            favoritesProvider: favoritesProvider))
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(viewModel.favoriteReadings) { reading in
                    VStack {
                        Text(reading.value)
                            .font(.title)
                        Text(reading.name)
                            .font(.title2)
                    }
                    .padding()
                    .contentShape(Rectangle())
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(uiColor: UIColor.secondaryLabel))
                    )
                }
            }
        }
    }
}

extension SensorReading {
    var id: String {
        sensorClass + name + unit
    }
}

extension DashboardView {
    class ViewModel: ObservableObject {
        let SensorReadingsProvider: any SensorReadingsProvider
        let favoritesProvider: any FavoritesProvider

        private var cancellables = Set<AnyCancellable>()

        @Published var favoriteReadings: [ReadingsListViewModel.ReadingModel] = []

        init(SensorReadingsProvider: any SensorReadingsProvider,
             favoritesProvider: any FavoritesProvider) {
            self.SensorReadingsProvider = SensorReadingsProvider
            self.favoritesProvider = favoritesProvider
            Task {
                await load()
            }
        }

        @MainActor
        func load() async {
            let readings = Future<[any SensorReading], Error> { [SensorReadingsProvider] promise in
                Task {
                    do {
                        let readings = try await SensorReadingsProvider.readings()
                        promise(.success(readings))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
            readings.combineLatest(favoritesProvider.favorites)
                .sink { completion in
                    print(completion)
                } receiveValue: { [weak self] readings, favorites in
                    guard let self = self else { return }
                    self.favoriteReadings = readings.filter { reading in
                        favorites.contains { favorite in
                            reading.id == favorite.id
                        }
                    }.map {
                        ReadingsListViewModel.ReadingModel(id: $0.id, name: $0.name, value: "\($0.value)\($0.unit)")
                    }
                }.store(in: &cancellables)
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    struct MockProvider: SensorReadingsProvider {
        struct MockReading: SensorReading {
            var sensorClass: String { "Class" }
            var name: String
            var value: String
            var unit: String
            var updateTime: Date { Date() }
        }

        var mockReadings: [MockReading] = [
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

        func readings() async throws -> [MockReading] {
            return mockReadings
        }
    }

    struct MockFavoriteProvider: FavoritesProvider {
        let favorites: CurrentValueSubject<[FavoriteModel], Error>

        init() {
            let mock = ReadingsList_Previews.MockProvider().mockReadings.value.first!
            let model = ReadingsListViewModel.ReadingModel(id: mock.id, name: mock.name, value: "\(mock.value)\(mock.unit)")
            favorites = CurrentValueSubject([
                .init(id: model.id)
            ])
        }
    }
    static var previews: some View {
        DashboardView(
            SensorReadingsProvider: MockProvider(),
            favoritesProvider: MockFavoriteProvider()
        )
    }
}

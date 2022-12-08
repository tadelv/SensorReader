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
                        HStack {
                            Text(reading.value)
                                .font(.title)
                            Text(reading.unit)
                                .font(.title)
                        }
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

        @Published var favoriteReadings: [ReadingsList.ReadingModel] = []

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
                    }.map(ReadingsList.ReadingModel.init(from:))
                }.store(in: &cancellables)
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    struct MockFavoriteProvider: FavoritesProvider {
        let favorites: CurrentValueSubject<[FavoriteModel], Error>

        init() {
            let mock = ReadingsList_Previews.MockProvider().mockReadings.first!
            let model = ReadingsList.ReadingModel(from: mock)
            favorites = CurrentValueSubject([
                .init(id: model.id)
            ])
        }
    }
    static var previews: some View {
        DashboardView(
            SensorReadingsProvider: ReadingsList_Previews.MockProvider(),
            favoritesProvider: MockFavoriteProvider()
        )
    }
}

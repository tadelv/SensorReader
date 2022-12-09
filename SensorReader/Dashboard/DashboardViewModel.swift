//
//  DashboardViewModel.swift
//  SensorReader
//
//  Created by Vid Tadel on 12/9/22.
//

import Combine

class DashboardViewModel: ObservableObject {
    let readingsProvider: any ReadingProviding
    let favoritesProvider: any FavoritesProvider

    private var cancellables = Set<AnyCancellable>()

    @Published var favoriteReadings: [ReadingsListViewModel.ReadingModel] = []

    init(readingsProvider: any ReadingProviding,
         favoritesProvider: any FavoritesProvider) {
        self.readingsProvider = readingsProvider
        self.favoritesProvider = favoritesProvider
        Task {
            await load()
        }
    }

    @MainActor
    func load() async {
        readingsProvider
            .readings
            .combineLatest(favoritesProvider.favorites)
            .sink { completion in
                print(completion)
            } receiveValue: { [weak self] readings, favorites in
                guard let self = self else { return }
                self.favoriteReadings = readings.filter { reading in
                    favorites.contains { favorite in
                        reading.id == favorite.id
                    }
                }.map {
                    ReadingsListViewModel.ReadingModel(id: $0.id,
                                                       device: $0.device,
                                                       name: $0.name,
                                                       value: "\($0.value)\($0.unit)")
                }
            }.store(in: &cancellables)
    }
}

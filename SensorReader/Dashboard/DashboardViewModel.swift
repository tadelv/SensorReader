//
//  DashboardViewModel.swift
//  SensorReader
//
//  Created by Vid Tadel on 12/9/22.
//

import Foundation
import Combine

class DashboardViewModel: ObservableObject {
    let readingsProvider: any ReadingProviding
    let favoritesProvider: any FavoritesProviding

    private var cancellables = Set<AnyCancellable>()
    private var readingsConnection: AnyCancellable?

    @Published var favoriteReadings: [ReadingModel] = []
    @Published var state: ViewModelState = .idle

    init(readingsProvider: any ReadingProviding,
         favoritesProvider: any FavoritesProviding) {
        self.readingsProvider = readingsProvider
        self.favoritesProvider = favoritesProvider
    }

    func attach() {
        state = .loading
        Task {
            await load()
        }
    }

    func load() async {
        readingsConnection = readingsProvider
            .readings
            .combineLatest(favoritesProvider.favorites)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] completion in
                if case let .failure(err) = completion {
                    state = .error(err)
                }
            } receiveValue: { [unowned self] readings, favorites in
                favoriteReadings = readings.filter { reading in
                    favorites.contains { favorite in
                        reading.id == favorite.id
                    }
                }.map {
                    ReadingModel(id: $0.id,
                                 device: $0.device,
                                 name: $0.name,
                                 value: "\($0.value)\($0.unit)")
                }
                state = .idle
            }
    }
}

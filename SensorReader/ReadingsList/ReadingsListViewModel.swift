//
//  ReadingsListViewModel.swift
//  SensorReader
//
//  Created by Vid Tadel on 12/8/22.
//

import Foundation
import Combine

@MainActor
class ReadingsListViewModel: ObservableObject {
    @Published var state: ViewModelState = .idle
    @Published var readings: [ReadingModel] = []
    private var favorites: [FavoriteModel] = []

    private var cancellables = Set<AnyCancellable>()
    private var readingsConnection: AnyCancellable?

    let provider: any ReadingProviding
    let favoritesProvider: any FavoritesProviding

    init(provider: any ReadingProviding,
         favorites: any FavoritesProviding) {
        self.provider = provider
        self.favoritesProvider = favorites


        self.favoritesProvider.favorites.sink { [unowned self] completion in
            if case let .failure(error) = completion {
                state = .error(error)
            }
        } receiveValue: { [unowned self] value in
            self.favorites = value
        }
        .store(in: &cancellables)
    }

    func load() async {
        state = .loading
        readingsConnection = provider.readings
            .receive(on: DispatchQueue.main)
            .map({ readings in
            readings.map {
                ReadingModel(id: $0.id,
                             device: $0.device,
                             name: $0.name,
                             value: "\($0.value)\($0.unit)")
            }
        })
        .sink(receiveCompletion: { [unowned self] failure in
            if case let .failure(error) = failure {
                state = .error(error)
            }
        }, receiveValue: { [unowned self] models in
            readings = models
            state = .idle
        })
    }

    func toggleFavorite(_ reading: ReadingModel) {
        switch favorites.contains(.init(id: reading.id)) {
        case true:
            Task {
                try? await favoritesProvider.remove(.init(id: reading.id))
                state = .idle
            }
        case false:
            Task {
                try? await favoritesProvider.add(.init(id: reading.id))
                state = .idle
            }
        }
    }

    func isFavorite(_ reading: ReadingModel) -> Bool {
        favorites.contains(.init(id: reading.id))
    }
}

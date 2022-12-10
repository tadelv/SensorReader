//
//  FavoritesProviding.swift
//  SensorReader
//
//  Created by Vid Tadel on 12/10/22.
//

import Combine

struct FavoriteModel: Equatable {
    let id: String
}

protocol FavoritesProviding {
    var favorites: CurrentValueSubject<[FavoriteModel], Error> { get }
}

// MARK: UseCase DI
protocol PersistenceProviding {
    associatedtype Content
    func store(_ value: Content?) throws
    func fetch() async throws -> Content?
}

// MARK: - Implementation
final class FavoritesUseCase<P: PersistenceProviding>: FavoritesProviding where P.Content == [FavoriteModel] {
    let favorites: CurrentValueSubject<[FavoriteModel], Error> = .init([])

    private let store: P
    private var cancellables: Set<AnyCancellable> = []

    init(store: P) {
        self.store = store
        favorites.sink { _ in

        } receiveValue: { [unowned self] newValue in
            do {
                try self.store.store(newValue)
            } catch {
                favorites.send(completion: .failure(error))
            }
        }.store(in: &cancellables)

        Task { [weak self, store] in
            do {
                let favorites = try await store.fetch()
                self?.favorites.send(favorites ?? [])
            } catch {
                self?.favorites.send(completion: .failure(error))
            }
        }
    }
}

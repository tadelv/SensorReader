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
    var favorites: AnyPublisher<[FavoriteModel], Error> { get }
    func add(_ favorite: FavoriteModel) async throws
    func remove(_ favorite: FavoriteModel) async throws
}

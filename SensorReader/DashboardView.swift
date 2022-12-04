//
//  DashboardView.swift
//  SensorReader
//
//  Created by Vid Tadel on 12/4/22.
//

import SensorReaderKit
import SwiftUI

struct FavoriteModel {
    let id: String
}

protocol FavoritesProvider {
    var favorites: [FavoriteModel] { get async throws }
}

struct DashboardView: View {
    @ObservedObject private var viewModel: ViewModel

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    init(readingsProvider: any ReadingsProvider,
         favoritesProvider: any FavoritesProvider) {
        _viewModel = ObservedObject(initialValue: ViewModel(readingsProvider: readingsProvider,
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
        let readingsProvider: any ReadingsProvider
        let favoritesProvider: any FavoritesProvider

        @Published var favoriteReadings: [ReadingsList.ReadingModel] = []

        init(readingsProvider: any ReadingsProvider,
             favoritesProvider: any FavoritesProvider) {
            self.readingsProvider = readingsProvider
            self.favoritesProvider = favoritesProvider
            Task {
                await load()
            }
        }

        @MainActor
        func load() async {
            do {
                let readings = try await readingsProvider.readings()
                let favorites = try await favoritesProvider.favorites
                favoriteReadings = readings.filter { reading in
                    favorites.contains { favorite in
                        reading.id == favorite.id
                    }
                }.map(ReadingsList.ReadingModel.init(from:))
            } catch {
                print("Show \(error)")
            }
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    struct MockFavoriteProvider: FavoritesProvider {
        var favorites: [FavoriteModel]

        init() {
            let mock = ReadingsList_Previews.MockProvider().mockReadings.first!
            let model = ReadingsList.ReadingModel(from: mock)
            favorites = [
                .init(id: model.id)
            ]
        }
    }
    static var previews: some View {
        DashboardView(
            readingsProvider: ReadingsList_Previews.MockProvider(),
            favoritesProvider: MockFavoriteProvider()
        )
    }
}

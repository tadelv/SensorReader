//
//  CompositionRoot.swift
//  SensorReader
//
//  Created by Vid Tadel on 1/6/23.
//

import SensorReaderKit
import SwiftUI

struct CompositionRoot {
    let reader: SensorReader
    let readingsUseCase: ReadingProviding
    let favoritesUseCase: FavoritesUseCase<UserDefaultsStore>
    let favoritesStore = UserDefaultsStore()

    init() {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 5
        config.timeoutIntervalForResource = 5
        let session = URLSession(configuration: config)
        guard let url = URL(string: "http://192.168.2.159:45678") else {
            fatalError("url could not be constructed")
        }
        self.reader = SensorReader(session, url: url)
        self.readingsUseCase = HomeView_Previews.mockReadingsProvider//ReadingsUseCase(reader: reader)
        self.favoritesUseCase = FavoritesUseCase(store: favoritesStore)
    }

    @MainActor
    var compose: some View {
        HomeView {
            DashboardView(viewModel: DashboardViewModel(readingsProvider: readingsUseCase,
                                                        favoritesProvider: favoritesUseCase))
            .tabItem {
                Image(systemName: "star")
            }
            NavigationView {
                ReadingsList(viewModel: ReadingsListViewModel(provider: readingsUseCase,
                                                              favorites: favoritesUseCase))
            }.tabItem {
                Image(systemName: "list.bullet")
            }
        }
    }
}

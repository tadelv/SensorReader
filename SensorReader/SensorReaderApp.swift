//
//  SensorReaderApp.swift
//  SensorReader
//
//  Created by Vid Tadel on 12/4/22.
//

import SwiftUI
import SensorReaderKit

@main
struct SensorReaderApp: App {
    var isUnitTesting: Bool {
        return ProcessInfo.processInfo.environment["UNITTEST"] == "1"
    }

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
        self.readingsUseCase = ReadingsUseCase(reader: reader)
        self.favoritesUseCase = FavoritesUseCase(store: favoritesStore)
    }

    var body: some Scene {
        WindowGroup {
            if isUnitTesting {
                EmptyView()
            } else {
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
    }
}

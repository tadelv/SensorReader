//
//  CompositionRoot.swift
//  SensorReader
//
//  Created by Vid Tadel on 1/6/23.
//

import SensorReaderKit
import SwiftUI

private let userDefaultsUrlKey = "server-url"

struct CompositionRoot {
    let readingsUseCase: ReadingsUseCase
    let favoritesUseCase: FavoritesUseCase<UserDefaultsStore>
    let favoritesStore = UserDefaultsStore()

    let settingsViewModel: SettingsViewModel

    init() {
        self.readingsUseCase = ReadingsUseCase(reader: UnconfiguredReader())
        self.favoritesUseCase = FavoritesUseCase(store: favoritesStore)

        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 5
        config.timeoutIntervalForResource = 5
        let session = URLSession(configuration: config)

        settingsViewModel = SettingsViewModel { [readingsUseCase] url in
            readingsUseCase.reader = SensorReader(session, url: url)
            //clunky restart
            _ = readingsUseCase.readings.sink { _ in

            } receiveValue: { _ in

            }
        } loadUrl: {
            UserDefaults.standard.url(forKey: userDefaultsUrlKey)
        } storeUrl: { url in
            UserDefaults.standard.set(url, forKey: userDefaultsUrlKey)
        }


    }

    var compose: some View {
        RootView(settingsViewModel: settingsViewModel,
                 readingsUseCase: readingsUseCase,
                 favoritesUseCase: favoritesUseCase)
    }
}

struct UnconfiguredReader: SensorReadingsProvider {
    struct Unconfigured: LocalizedError {
        var errorDescription: String = "Not configured"
    }
    func readings() async throws -> [any SensorReading] {
        throw Unconfigured()
    }
}

struct RootView: View {
    @ObservedObject var settingsViewModel: SettingsViewModel
    let readingsUseCase: ReadingsUseCase
    let favoritesUseCase: FavoritesUseCase<UserDefaultsStore>

    init(settingsViewModel: SettingsViewModel, readingsUseCase: ReadingsUseCase, favoritesUseCase: FavoritesUseCase<UserDefaultsStore>) {
        self.settingsViewModel = settingsViewModel
        self.readingsUseCase = readingsUseCase
        self.favoritesUseCase = favoritesUseCase
    }

    var body: some View {
        HomeView {
            NavigationView {
                DashboardView(viewModel: DashboardViewModel(readingsProvider: readingsUseCase,
                                                            favoritesProvider: favoritesUseCase))
                .toolbar {
                    Button {
                        settingsViewModel.settingsVisible = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
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
        .sheet(isPresented: $settingsViewModel.settingsVisible) {
            SettingsView(serverUrl: $settingsViewModel.serverUrl,
                         urlValid: $settingsViewModel.urlInvalid) {
                settingsViewModel.validateAndContinue()
                settingsViewModel.settingsVisible = false
            }
            .interactiveDismissDisabled(settingsViewModel.urlInvalid)
        }
        .onAppear {
            settingsViewModel.checkConfiguration()
        }
    }
}

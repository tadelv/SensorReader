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

    let reader: SensorReader
    let useCase: ReadingsUseCase

    init() {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 5
        config.timeoutIntervalForResource = 5
        let session = URLSession(configuration: config)
        self.reader = SensorReader(session)
        self.useCase = ReadingsUseCase(reader: reader)
    }

    var body: some Scene {
        WindowGroup {
            HomeView {
                NavigationView {
                    ReadingsList(viewModel: ReadingsListViewModel(provider: useCase))
                }.tabItem {
                    Image(systemName: "list.bullet")
                }
            }
        }
    }
}

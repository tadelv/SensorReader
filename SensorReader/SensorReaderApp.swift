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
    let useCase: ReadingsUseCase

    init() {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 5
        config.timeoutIntervalForResource = 5
        let session = URLSession(configuration: config)
        guard let url = URL(string: "http://192.168.2.159:45678") else {
            fatalError("url could not be constructed")
        }
        self.reader = SensorReader(session, url: url)
        self.useCase = ReadingsUseCase(reader: reader)
    }

    var body: some Scene {
        WindowGroup {
            if isUnitTesting {
                EmptyView()
            } else {
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
}

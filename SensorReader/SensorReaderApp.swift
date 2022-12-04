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

    init() {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 5
        config.timeoutIntervalForResource = 5
        let session = URLSession(configuration: config)
        self.reader = SensorReader(session)
    }

    var body: some Scene {
        WindowGroup {
            HomeView {
                NavigationView {
                    ReadingsList(provider: reader)
                }.tabItem {
                    Image(systemName: "list.bullet")
                }
            }
        }
    }
}

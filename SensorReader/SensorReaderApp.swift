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
    let reader = SensorReader(URLSession.shared)
    var body: some Scene {
        WindowGroup {
            ReadingsList(provider: reader)
        }
    }
}

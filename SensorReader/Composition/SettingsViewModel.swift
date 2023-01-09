//
//  SettingsViewModel.swift
//  SensorReader
//
//  Created by Vid Tadel on 1/6/23.
//

import Foundation
import Combine


final class SettingsViewModel: ObservableObject {
    @Published var serverUrl = ""
    @Published var urlInvalid = false
    @Published var settingsVisible = false

    let configurationDone: (URL) -> Void

    private var cancellables = Set<AnyCancellable>()

    init(_ configCallback: @escaping (URL) -> Void) {
        self.configurationDone = configCallback

        $serverUrl.sink { [unowned self] val in
            guard let _ = URL(string: val) else {
                urlInvalid = true
                return
            }
            urlInvalid = false
        }.store(in: &cancellables)
    }

    func checkConfiguration() {
        guard let urlString = UserDefaults.standard.string(forKey: "server-url"),
              let url = URL(string: urlString) else {
            urlInvalid = true
            settingsVisible = true
            return
        }
        serverUrl = urlString
        configurationDone(url)
    }

    func validateAndContinue() {
        guard let url = URL(string: serverUrl) else {
            urlInvalid = true
            return
        }
        UserDefaults.standard.set(serverUrl, forKey: "server-url")
        configurationDone(url)
    }
}

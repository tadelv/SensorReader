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
    let loadUrl: () -> URL?
    let storeUrl: (URL) -> Void

    private var cancellables = Set<AnyCancellable>()

    init(_ configCallback: @escaping (URL) -> Void,
         loadUrl: @escaping () -> URL?,
         storeUrl: @escaping (URL) -> Void) {
        self.configurationDone = configCallback
        self.loadUrl = loadUrl
        self.storeUrl = storeUrl

        $serverUrl.sink { [unowned self] val in
            guard let _ = URL(string: val) else {
                urlInvalid = true
                return
            }
            urlInvalid = false
        }.store(in: &cancellables)
    }

    func checkConfiguration() {
        guard let url = loadUrl() else {
            urlInvalid = true
            settingsVisible = true
            return
        }
        serverUrl = url.absoluteString
        configurationDone(url)
    }

    func validateAndContinue() {
        guard let url = URL(string: serverUrl) else {
            urlInvalid = true
            return
        }
        storeUrl(url)
        configurationDone(url)
    }
}

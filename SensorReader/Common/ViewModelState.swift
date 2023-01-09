//
//  ViewModelState.swift
//  SensorReader
//
//  Created by Vid Tadel on 12/9/22.
//

import Foundation

enum ViewModelState: Equatable {
    case idle
    case loading
    case error(ModelError)

    static let error: (Error) -> ViewModelState = { error in
        ViewModelState.error(ModelError(error))
    }
}

struct ModelError: Error, Equatable {
    var localizedDescription: String

    init(_ error: any Error) {
        self.localizedDescription = error.localizedDescription
    }
}

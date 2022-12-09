//
//  ViewModelState.swift
//  SensorReader
//
//  Created by Vid Tadel on 12/9/22.
//

import Foundation

enum ViewModelState {
    case idle
    case loading
    case error(Error)
}

//
//  DashboardView.swift
//  SensorReader
//
//  Created by Vid Tadel on 12/4/22.
//

import Combine
import SensorReaderKit
import SwiftUI

struct FavoriteModel {
    let id: String
}

protocol FavoritesProvider {
    var favorites: CurrentValueSubject<[FavoriteModel], Error> { get }
}

struct DashboardView: View {
    @ObservedObject private var viewModel: DashboardViewModel

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    init(viewModel: DashboardViewModel) {
        _viewModel = ObservedObject(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(viewModel.favoriteReadings) { reading in
                    VStack {
                        Text(reading.value)
                            .font(.title)
                        Text(reading.name)
                            .font(.title2)
                    }
                    .padding()
                    .contentShape(Rectangle())
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(uiColor: UIColor.secondaryLabel))
                    )
                }
            }
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    struct MockFavoriteProvider: FavoritesProvider {
        let favorites: CurrentValueSubject<[FavoriteModel], Error>

        init() {
            let mock = MockProvider().mockReadings.value.first!
            let model = ReadingModel(id: mock.id,
                                     device: mock.device,
                                     name: mock.name,
                                     value: "\(mock.value)\(mock.unit)")
            favorites = CurrentValueSubject([
                .init(id: model.id)
            ])
        }
    }
    static var previews: some View {
        DashboardView(viewModel: DashboardViewModel(readingsProvider: MockProvider(), favoritesProvider: MockFavoriteProvider())
        )
    }
}

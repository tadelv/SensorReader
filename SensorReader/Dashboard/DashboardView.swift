//
//  DashboardView.swift
//  SensorReader
//
//  Created by Vid Tadel on 12/4/22.
//

import Combine
import SensorReaderKit
import SwiftUI

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
                    .frame(maxWidth: .infinity)
                    .padding()
                    .contentShape(Rectangle())
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(uiColor: UIColor.secondaryLabel))
                    )
                }
            }
            .padding()
        }
        .onAppear {
            viewModel.attach()
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView(
            viewModel: DashboardViewModel(
                readingsProvider: Self.mockReadingsProvider,
                favoritesProvider: Self.mockFavoritesProvider)
        )
    }
}

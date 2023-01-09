//
//  ReadingsList.swift
//  SensorReader
//
//  Created by Vid Tadel on 12/4/22.
//

import Combine
import SwiftUI
import SensorReaderKit


struct ReadingsList: View {
    @ObservedObject private var viewModel: ReadingsListViewModel
    @State var searchText = ""

    init(viewModel: ReadingsListViewModel) {
        _viewModel = ObservedObject(initialValue: viewModel)
    }

    var searchResults: [ReadingModel] {
        if searchText.isEmpty {
            return viewModel.readings
        }
        return viewModel.readings.filter {
            $0.name.lowercased().contains(searchText) ||
            $0.device.lowercased().contains(searchText)
        }
    }

    var body: some View {
        ZStack {
            List {
                ForEach(searchResults) { reading in
                    ReadingsListCell(reading: reading,
                                     isFavorite: viewModel.isFavorite(reading),
                                     buttonTap: {
                        viewModel.toggleFavorite(reading)
                    })
                }
            }.opacity(viewModel.state == .idle ? 1.0 : 0.0)
            if case .loading = viewModel.state {
                VStack {
                    ProgressView()
                    Text("Loading")
                        .background(Color(UIColor.systemBackground))
                }
            }
            if case .error(let err) = viewModel.state {
                let message = "Failed with: \(err.localizedDescription)"
                Text(message)
                    .background(Color(UIColor.systemBackground))
            }
        }
        .onAppear {
            refresh()
        }
        .toolbar {
            Button {
                refresh()
            } label: {
                Image(systemName: "arrow.clockwise")
            }

        }
        .navigationTitle("List")
        .searchable(text: $searchText)
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
    }

    func refresh() {
        Task {
            await viewModel.load()
        }
    }
}

struct ReadingsList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ReadingsList(
                viewModel: ReadingsListViewModel(provider: Self.mockReadingsProvider,
                                                 favorites: Self.mockFavoritesProvider)
            )
        }
    }
}

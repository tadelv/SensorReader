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

    init(viewModel: ReadingsListViewModel) {
        _viewModel = ObservedObject(initialValue: viewModel)
    }

    var body: some View {
        ZStack {
            List {
                ForEach(viewModel.readings) { reading in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(reading.name)
                            Text(reading.device).font(.caption)
                        }
                        Spacer()
                        Text(reading.value)
                            .font(.callout)
                    }
                }
            }
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
    }

    func refresh() {
        Task {
            await viewModel.load()
        }
    }
}

struct ReadingsList_Previews: PreviewProvider {
    static var previews: some View {
        ReadingsList(viewModel: ReadingsListViewModel(provider: MockProvider()))
    }
}

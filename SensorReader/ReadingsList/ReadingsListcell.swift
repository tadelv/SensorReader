//
//  ReadingsListcell.swift
//  SensorReader
//
//  Created by Vid Tadel on 12/30/22.
//

import SwiftUI

struct ReadingsListCell: View {
    let reading: ReadingModel
    let isFavorite: Bool
    let buttonTap: () -> Void

    var body: some View {
        HStack {
            Button(action: buttonTap) {
                Image(systemName: "star.fill")
                    .foregroundColor(isFavorite ? .blue : .gray)
            }
            VStack(alignment: .leading) {
                Text(reading.name)
                Text(reading.device).font(.caption)
            }
            Spacer()
            Text(reading.value)
                .font(.callout)
        }
        .padding([.top, .bottom])
    }
}

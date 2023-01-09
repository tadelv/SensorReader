//
//  SettingsView.swift
//  SensorReader
//
//  Created by Vid Tadel on 1/6/23.
//

import SwiftUI

struct SettingsView: View {
    @Binding var serverUrl: String
    @Binding var urlValid: Bool
    let callback: () -> Void
    var body: some View {
        Form {
            Section("Server url") {
                TextField("Set url", text: $serverUrl)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            }
            Button("Done") {
                callback()
            }
            .frame(maxWidth: .infinity)
            .disabled(urlValid)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(serverUrl: .constant("http://192.168.2.159:45678"),
                     urlValid: .constant(true)) {}
    }
}

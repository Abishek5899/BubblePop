//
//  SettingsView.swift
//  PoptheBubble
//
//  Created by Grown Nomad on 15/4/2025.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        Form {
            Section(header: Text("Game Settings")) {
                Stepper(value: $viewModel.gameDuration, in: 10...180, step: 5) {
                    Text("Game Duration: \(viewModel.gameDuration) sec")
                }

                Stepper(value: $viewModel.maxBubbles, in: 5...30, step: 1) {
                    Text("Max Bubbles: \(viewModel.maxBubbles)")
                }
            }
        }
        .navigationTitle("Settings")
    }
}

//
//  ScoreBoardView.swift
//  PoptheBubble
//
//  Created by Grown Nomad on 18/4/2025.
//

import SwiftUI

struct ScoreboardView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("🏆 High Scores")
                .font(.largeTitle)
                .fontWeight(.bold)

            if viewModel.highScores.isEmpty {
                Text("No scores yet.")
                    .foregroundColor(.gray)
            } else {
                List {
                    ForEach(viewModel.highScores.sorted(by: { $0.score > $1.score })) { entry in
                        HStack {
                            Text(entry.name)
                                .fontWeight(.medium)
                            Spacer()
                            Text("\(entry.score)")
                                .font(.headline)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(.insetGrouped)
            }

            Spacer()
        }
        .padding()
        .onAppear {
            viewModel.loadHighScores()
        }
    }
}

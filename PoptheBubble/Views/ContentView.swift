import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                GeometryReader { geometry in
                    ZStack {
                        LinearGradient(
                            gradient: Gradient(colors: [Color.white, Color.yellow]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .ignoresSafeArea()

                        VStack {
                            // Top HUD bar
                            HStack(spacing: 8) {
                                if viewModel.gameStarted {
                                    Text("👋 \(viewModel.playerName)")
                                    Spacer()
                                    Text("⏳ \(viewModel.timeLeft)s")
                                    Spacer()
                                    Text("Score: \(viewModel.score)")
                                    Spacer()
                                    Text("High: \(viewModel.topScore)")
                                } else {
                                    Spacer()
                                }

                                NavigationLink(destination: SettingsView(viewModel: viewModel)) {
                                    Image(systemName: "gearshape.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .font(.headline)
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.2))

                            Spacer()

                            VStack(spacing: 20) {
                                if !viewModel.gameStarted {
                                    Text("🎈BubblePop 🎈")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)

                                    TextField("Enter Player Name", text: $viewModel.playerName)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .padding(.horizontal, 40)

                                    Button(action: {
                                        if !viewModel.playerName.isEmpty {
                                            viewModel.startCountdown(screenSize: geometry.size)
                                        }
                                    }) {
                                        Text("Start")
                                            .font(.headline)
                                            .padding()
                                            .background(Color.white.opacity(0.9))
                                            .foregroundColor(.blue)
                                            .cornerRadius(10)
                                    }

                                    NavigationLink("High Scores") {
                                        ScoreboardView(viewModel: viewModel)
                                    }
                                    .buttonStyle(.bordered)
                                }

                                else if viewModel.gameEnded {
                                    Text("⏰ Time's Up!")
                                        .font(.title2)
                                        .foregroundColor(.black)

                                    Text("Final Score: \(viewModel.score)")
                                        .font(.title2)
                                        .foregroundColor(.black)

                                    NavigationLink("View Scoreboard") {
                                        ScoreboardView(viewModel: viewModel)
                                    }
                                    .buttonStyle(.borderedProminent)
                                }
                            }

                            Spacer()
                        }

                        // ✅ EF2.1: Countdown Animation
                        if viewModel.showCountdown {
                            Text("\(viewModel.countdownValue)")
                                .font(.system(size: 100, weight: .bold))
                                .foregroundColor(.red)
                                .scaleEffect(1.5)
                                .transition(.scale.combined(with: .opacity))
                                .id(viewModel.countdownValue)
                                .animation(.easeInOut(duration: 0.8), value: viewModel.countdownValue)
                                .position(x: UIScreen.main.bounds.width / 2, y: 150)
                        }

                        ForEach(viewModel.bubbles) { bubble in
                            Circle()
                                .fill(bubble.color)
                                .frame(width: 60, height: 60)
                                .scaleEffect(viewModel.poppingBubbleIDs.contains(bubble.id) ? 0.1 : 1.0)
                                .opacity(viewModel.poppingBubbleIDs.contains(bubble.id) ? 0.2 : 1.0)
                                .position(bubble.position)
                                .animation(.easeInOut(duration: 0.2), value: viewModel.poppingBubbleIDs)
                                .onTapGesture {
                                    viewModel.popBubble(bubble)
                                }
                        }
                        ForEach(viewModel.scorePopups) { popup in
                            Text(popup.text)
                                .font(.headline)
                                .foregroundColor(.black)
                                .position(popup.position)
                                .offset(y: -30)
                                .opacity(0.8)
                                .transition(.move(edge: .top).combined(with: .opacity))
                                .animation(.easeOut(duration: 1), value: popup.id)
                        }
                    }
                    .animation(.easeInOut, value: viewModel.bubbles)
                }
            }
            .navigationDestination(isPresented: $viewModel.navigateToHome) {
                ContentView()
            }
            .onAppear {
                viewModel.loadHighScores()
            }
        }
    }
}

#Preview {
    ContentView()
}


import SwiftUI

class GameViewModel: ObservableObject {
    //Game State Variables
    @Published var playerName: String = ""
    @Published var gameStarted: Bool = false
    @Published var timeLeft: Int = 60
    @Published var score: Int = 0
    @Published var gameEnded: Bool = false
    @Published var bubbles: [Bubble] = []

    //Settings Variables
    @Published var gameDuration: Int = 60
    @Published var maxBubbles: Int = 15

    //Highscore Variables
    @Published var highScores: [HighScore] = []
    @Published var navigateToHome: Bool = false
    
    @Published var scorePopups: [ScorePopup] = []

    //Countdown Variables
    @Published var showCountdown: Bool = false
    @Published var countdownValue: Int = 3

    @Published var poppingBubbleIDs: Set<UUID> = []
    private var timer: Timer?
    private var lastPoppedColor: String? = nil
    private var comboCount: Int = 0

    private let highScoresKey = "BubblePopHighScores"

    
    
    struct ScorePopup: Identifiable {
        let id = UUID()
        let text: String
        let position: CGPoint
    }
    
    var topScore: Int {
        highScores.sorted(by: { $0.score > $1.score }).first?.score ?? 0
    }

    func startCountdown(screenSize: CGSize) {
        gameStarted = false
        gameEnded = false
        countdownValue = 3
        showCountdown = true

        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.countdownValue -= 1
            if self.countdownValue == 0 {
                timer.invalidate()
                self.showCountdown = false
                self.startGame(screenSize: screenSize)
            }
        }
    }

    func startGame(screenSize: CGSize) {
        //Initializing variables
        gameStarted = true
        timeLeft = gameDuration
        score = 0
        gameEnded = false
        comboCount = 0
        lastPoppedColor = nil
        
        spawnBubbles(screenSize: screenSize)

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.timeLeft > 0 {
                self.timeLeft -= 1
                self.spawnBubbles(screenSize: screenSize)
            } else {
                self.gameEnded = true
                self.timer?.invalidate()
                self.saveHighScore()
                
                //Return to home screen after 5 seconds of inactivity
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    if self.gameEnded {
                        self.navigateToHome = true
                    }
                }
            }
        }
    }

    func popBubble(_ bubble: Bubble) {
        if poppingBubbleIDs.contains(bubble.id) { return } // avoid double tap

            poppingBubbleIDs.insert(bubble.id)

            // Delay removal to allow animation to play
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                if let index = self.bubbles.firstIndex(of: bubble) {
                    var earnedPoints = bubble.points
                    if bubble.colorName == self.lastPoppedColor {
                        self.comboCount += 1
                        earnedPoints = Int(round(Double(bubble.points) * 1.5))
                    } else {
                        self.comboCount = 1
                    }
                    self.lastPoppedColor = bubble.colorName
                    self.score += earnedPoints
                 
                    let popup = ScorePopup(text: "+\(earnedPoints)", position: bubble.position)
                    self.scorePopups.append(popup)

                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.scorePopups.removeAll { $0.id == popup.id }
                    }
                    
                    self.bubbles.remove(at: index)
                }

                self.poppingBubbleIDs.remove(bubble.id)
            }
    }

    func spawnBubbles(screenSize: CGSize) {
        var placedBubbles: [Bubble] = []
        let bubbleSize: CGFloat = 60
        let radius = bubbleSize / 2
        let bubbleCount = Int.random(in: 5...maxBubbles)
        var attempts = 0

        while placedBubbles.count < bubbleCount && attempts < 500 {
            attempts += 1
            let x = CGFloat.random(in: radius...(screenSize.width - radius))
            let y = CGFloat.random(in: 150...(screenSize.height - radius))
            let position = CGPoint(x: x, y: y)

            let overlaps = placedBubbles.contains { existing in
                let dx = existing.position.x - position.x
                let dy = existing.position.y - position.y
                return sqrt(dx * dx + dy * dy) < bubbleSize
            }

            if !overlaps {
                let colorChance = Int.random(in: 1...100)
                let colorName: String
                let points: Int

                switch colorChance {
                case 1...40: colorName = "red"; points = 1
                case 41...70: colorName = "pink"; points = 2
                case 71...85: colorName = "green"; points = 5
                case 86...95: colorName = "blue"; points = 8
                default: colorName = "black"; points = 10
                }

                placedBubbles.append(Bubble(colorName: colorName, points: points, position: position))

            }
        }

        DispatchQueue.main.async {
            self.bubbles = placedBubbles
        }
    }

    func saveHighScore() {
        loadHighScores()
        if let existingIndex = highScores.firstIndex(where: { $0.name == playerName }) {
            if score > highScores[existingIndex].score {
                highScores[existingIndex].score = score
            }
        } else {
            highScores.append(HighScore(name: playerName, score: score))
        }

        if let encoded = try? JSONEncoder().encode(highScores) {
            UserDefaults.standard.set(encoded, forKey: highScoresKey)
        }
    }

    func loadHighScores() {
        if let data = UserDefaults.standard.data(forKey: highScoresKey),
           let decoded = try? JSONDecoder().decode([HighScore].self, from: data) {
            highScores = decoded
        }
    }
}


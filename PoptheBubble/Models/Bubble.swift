import SwiftUI

struct Bubble: Identifiable, Equatable {
    let id = UUID()
    let colorName: String
    let points: Int
    var position: CGPoint

    var color: Color {
        switch colorName {
        case "red": return .red
        case "pink": return .pink
        case "green": return .green
        case "blue": return .blue
        case "black": return .black
        default: return .gray
        }
    }

    static func == (lhs: Bubble, rhs: Bubble) -> Bool {
        lhs.id == rhs.id
    }
}


//
//  HighScore.swift
//  PoptheBubble
//
//  Created by Grown Nomad on 18/4/2025.
//

import Foundation

struct HighScore: Codable, Identifiable, Equatable {
    var id: String { name } // use name as unique ID
    let name: String
    var score: Int
}

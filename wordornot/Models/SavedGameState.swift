//
//  SavedGameState.swift
//  wordornot
//
//  Created by mustafa ergisi on 8/10/25.
//

import Foundation

struct SavedGameState: Codable {
    let gameSession: GameSession
    let gameWords: [Word]
    let currentWordIndex: Int
}



//
//  GameSession.swift
//  wordornot
//
//  Created by mustafa ergisi on 8/10/25.
//

import Foundation

struct GameSession: Codable, Identifiable {
    let id = UUID()
    let startTime: Date
    var endTime: Date?
    var words: [WordResult]
    var score: Int
    var totalWords: Int
    var correctAnswers: Int
    var isCompleted: Bool
    var lives: Int
    var currentStreak: Int
    var maxStreak: Int
    
    init() {
        self.startTime = Date()
        self.endTime = nil
        self.words = []
        self.score = 0
        self.totalWords = 0
        self.correctAnswers = 0
        self.isCompleted = false
        self.lives = 3
        self.currentStreak = 0
        self.maxStreak = 0
    }
    
    var accuracy: Double {
        guard totalWords > 0 else { return 0.0 }
        return Double(correctAnswers) / Double(totalWords)
    }
    
    var duration: TimeInterval {
        guard let endTime = endTime else { return 0 }
        return endTime.timeIntervalSince(startTime)
    }
    
    mutating func addWordResult(_ wordResult: WordResult) {
        words.append(wordResult)
        totalWords += 1
        
        if wordResult.isCorrect {
            correctAnswers += 1
            score += wordResult.points
            currentStreak += 1
            maxStreak = max(maxStreak, currentStreak)
        } else {
            currentStreak = 0
            lives -= 1
        }
    }
    
    mutating func endGame() {
        endTime = Date()
        isCompleted = true
    }
    
    var isGameOver: Bool {
        return lives <= 0 || isCompleted
    }
    
    private enum CodingKeys: String, CodingKey {
        case startTime, endTime, words, score, totalWords, correctAnswers, isCompleted, lives, currentStreak, maxStreak
    }
}

struct WordResult: Codable, Identifiable {
    let id = UUID()
    let word: Word
    let userGuess: Bool // true for "real", false for "fake"
    let responseTime: TimeInterval
    let timestamp: Date
    
    var isCorrect: Bool {
        return userGuess == word.isReal
    }
    
    var points: Int {
        guard isCorrect else { return 0 }
        
        let basePoints = 10
        let difficultyMultiplier: Int
        
        switch word.difficulty {
        case .easy:
            difficultyMultiplier = 1
        case .medium:
            difficultyMultiplier = 2
        case .hard:
            difficultyMultiplier = 3
        }
        
        // Bonus points for quick responses (under 3 seconds)
        let speedBonus = responseTime < 3.0 ? 5 : 0
        
        return basePoints * difficultyMultiplier + speedBonus
    }
    
    private enum CodingKeys: String, CodingKey {
        case word, userGuess, responseTime, timestamp
    }
}

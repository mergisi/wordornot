//
//  GameStats.swift
//  wordornot
//
//  Created by mustafa ergisi on 8/10/25.
//

import Foundation

struct GameStats: Codable {
    var totalGamesPlayed: Int
    var totalWordsGuessed: Int
    var totalCorrectGuesses: Int
    var bestScore: Int
    var bestAccuracy: Double
    var totalPlayTime: TimeInterval
    var gamesHistory: [GameSession]
    var streakCount: Int
    var bestStreak: Int
    var lastPlayDate: Date?
    
    init() {
        self.totalGamesPlayed = 0
        self.totalWordsGuessed = 0
        self.totalCorrectGuesses = 0
        self.bestScore = 0
        self.bestAccuracy = 0.0
        self.totalPlayTime = 0
        self.gamesHistory = []
        self.streakCount = 0
        self.bestStreak = 0
        self.lastPlayDate = nil
    }
    
    var overallAccuracy: Double {
        guard totalWordsGuessed > 0 else { return 0.0 }
        return Double(totalCorrectGuesses) / Double(totalWordsGuessed)
    }
    
    var averageScore: Double {
        guard totalGamesPlayed > 0 else { return 0.0 }
        let totalScore = gamesHistory.reduce(0) { $0 + $1.score }
        return Double(totalScore) / Double(totalGamesPlayed)
    }
    
    var averagePlayTime: TimeInterval {
        guard totalGamesPlayed > 0 else { return 0.0 }
        return totalPlayTime / Double(totalGamesPlayed)
    }
    
    mutating func updateWithGameSession(_ session: GameSession) {
        guard session.isCompleted else { return }
        
        // Add to history
        gamesHistory.append(session)
        
        // Update basic stats
        totalGamesPlayed += 1
        totalWordsGuessed += session.totalWords
        totalCorrectGuesses += session.correctAnswers
        totalPlayTime += session.duration
        
        // Update best records
        if session.score > bestScore {
            bestScore = session.score
        }
        
        if session.accuracy > bestAccuracy {
            bestAccuracy = session.accuracy
        }
        
        // Update streak
        updateStreak(basedOn: session)
        
        // Update last play date
        lastPlayDate = session.endTime
        
        // Keep only last 100 games to prevent data bloat
        if gamesHistory.count > 100 {
            gamesHistory.removeFirst(gamesHistory.count - 100)
        }
    }
    
    private mutating func updateStreak(basedOn session: GameSession) {
        // Consider a game successful if accuracy is above 70%
        let isSuccessful = session.accuracy >= 0.7
        
        if isSuccessful {
            streakCount += 1
            if streakCount > bestStreak {
                bestStreak = streakCount
            }
        } else {
            streakCount = 0
        }
    }
    
    func getRecentGames(count: Int = 10) -> [GameSession] {
        return Array(gamesHistory.suffix(count))
    }
    
    func getStatsForTimeFrame(_ timeFrame: StatsTimeFrame) -> GameStats {
        let cutoffDate: Date
        let now = Date()
        
        switch timeFrame {
        case .week:
            cutoffDate = Calendar.current.date(byAdding: .day, value: -7, to: now) ?? now
        case .month:
            cutoffDate = Calendar.current.date(byAdding: .month, value: -1, to: now) ?? now
        case .year:
            cutoffDate = Calendar.current.date(byAdding: .year, value: -1, to: now) ?? now
        case .allTime:
            return self
        }
        
        let filteredGames = gamesHistory.filter { game in
            guard let endTime = game.endTime else { return false }
            return endTime >= cutoffDate
        }
        
        var timeFrameStats = GameStats()
        for game in filteredGames {
            timeFrameStats.updateWithGameSession(game)
        }
        
        return timeFrameStats
    }
}

enum StatsTimeFrame: String, CaseIterable {
    case week = "week"
    case month = "month"
    case year = "year"
    case allTime = "allTime"
    
    var displayName: String {
        switch self {
        case .week:
            return "This Week"
        case .month:
            return "This Month"
        case .year:
            return "This Year"
        case .allTime:
            return "All Time"
        }
    }
}

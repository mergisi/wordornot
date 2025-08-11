//
//  StatsViewModel.swift
//  wordornot
//
//  Created by mustafa ergisi on 8/10/25.
//

import Foundation
import SwiftUI

class StatsViewModel: ObservableObject {
    @Published var currentTimeFrame: StatsTimeFrame = .allTime
    @Published var gameStats: GameStats
    @Published var showingExportSheet = false
    @Published var showingImportSheet = false
    @Published var exportData: Data?
    
    private let dataManager = DataManager.shared
    
    init() {
        self.gameStats = dataManager.loadGameStats()
    }
    
    // MARK: - Data Management
    
    func refreshStats() {
        gameStats = dataManager.loadGameStats()
    }
    
    func changeTimeFrame(_ timeFrame: StatsTimeFrame) {
        currentTimeFrame = timeFrame
        updateStatsForTimeFrame()
    }
    
    private func updateStatsForTimeFrame() {
        let allTimeStats = dataManager.loadGameStats()
        gameStats = allTimeStats.getStatsForTimeFrame(currentTimeFrame)
    }
    
    // MARK: - Computed Properties
    
    var formattedOverallAccuracy: String {
        return String(format: "%.1f%%", gameStats.overallAccuracy * 100)
    }
    
    var formattedAverageScore: String {
        return String(format: "%.0f", gameStats.averageScore)
    }
    
    var formattedBestScore: String {
        return "\(gameStats.bestScore)"
    }
    
    var formattedBestAccuracy: String {
        return String(format: "%.1f%%", gameStats.bestAccuracy * 100)
    }
    
    var formattedTotalPlayTime: String {
        return formatDuration(gameStats.totalPlayTime)
    }
    
    var formattedAveragePlayTime: String {
        return formatDuration(gameStats.averagePlayTime)
    }
    
    var currentStreak: String {
        return "\(gameStats.streakCount)"
    }
    
    var bestStreak: String {
        return "\(gameStats.bestStreak)"
    }
    
    var totalGames: String {
        return "\(gameStats.totalGamesPlayed)"
    }
    
    var totalWords: String {
        return "\(gameStats.totalWordsGuessed)"
    }
    
    var lastPlayDate: String {
        guard let date = gameStats.lastPlayDate else { return "Never" }
        return formatDate(date)
    }
    
    // MARK: - Recent Games
    
    func getRecentGames(count: Int = 10) -> [GameSession] {
        return gameStats.getRecentGames(count: count)
    }
    
    // MARK: - Chart Data
    
    func getAccuracyTrend() -> [ChartDataPoint] {
        let recentGames = getRecentGames(count: 10)
        return recentGames.enumerated().map { index, game in
            ChartDataPoint(
                x: Double(index + 1),
                y: game.accuracy * 100,
                label: "Game \(index + 1)"
            )
        }
    }
    
    func getScoreTrend() -> [ChartDataPoint] {
        let recentGames = getRecentGames(count: 10)
        return recentGames.enumerated().map { index, game in
            ChartDataPoint(
                x: Double(index + 1),
                y: Double(game.score),
                label: "Game \(index + 1)"
            )
        }
    }
    
    func getDifficultyBreakdown() -> [DifficultyStats] {
        let allTimeStats = dataManager.loadGameStats()
        var difficultyStats: [Word.Difficulty: DifficultyStats] = [:]
        
        for difficulty in Word.Difficulty.allCases {
            difficultyStats[difficulty] = DifficultyStats(
                difficulty: difficulty,
                totalWords: 0,
                correctWords: 0,
                totalScore: 0
            )
        }
        
        for game in allTimeStats.gamesHistory {
            for wordResult in game.words {
                let difficulty = wordResult.word.difficulty
                difficultyStats[difficulty]?.totalWords += 1
                
                if wordResult.isCorrect {
                    difficultyStats[difficulty]?.correctWords += 1
                    difficultyStats[difficulty]?.totalScore += wordResult.points
                }
            }
        }
        
        return Array(difficultyStats.values).sorted { $0.difficulty.rawValue < $1.difficulty.rawValue }
    }
    
    // MARK: - Data Export/Import
    
    func exportStats() {
        exportData = dataManager.exportData()
        showingExportSheet = true
    }
    
    func importStats(from data: Data) -> Bool {
        let success = dataManager.importData(data)
        if success {
            refreshStats()
        }
        return success
    }
    
    func resetAllStats() {
        dataManager.clearAllData()
        gameStats = GameStats()
    }
    
    // MARK: - Formatting Helpers
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%dh %dm", hours, minutes)
        } else if minutes > 0 {
            return String(format: "%dm %ds", minutes, seconds)
        } else {
            return String(format: "%ds", seconds)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Types

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let x: Double
    let y: Double
    let label: String
}

struct DifficultyStats: Identifiable {
    let id = UUID()
    let difficulty: Word.Difficulty
    var totalWords: Int
    var correctWords: Int
    var totalScore: Int
    
    var accuracy: Double {
        guard totalWords > 0 else { return 0.0 }
        return Double(correctWords) / Double(totalWords)
    }
    
    var averageScore: Double {
        guard correctWords > 0 else { return 0.0 }
        return Double(totalScore) / Double(correctWords)
    }
    
    var formattedAccuracy: String {
        return String(format: "%.1f%%", accuracy * 100)
    }
}

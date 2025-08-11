//
//  GameViewModel.swift
//  wordornot
//
//  Created by mustafa ergisi on 8/10/25.
//

import Foundation
import SwiftUI

class GameViewModel: ObservableObject {
    @Published var currentWord: Word?
    @Published var gameSession: GameSession
    @Published var gameWords: [Word] = []
    @Published var currentWordIndex: Int = 0
    @Published var isGameActive: Bool = false
    @Published var isGameOver: Bool = false
    @Published var wordStartTime: Date = Date()
    @Published var showFeedback: Bool = false
    @Published var lastAnswerCorrect: Bool = false
    @Published var gameProgress: Double = 0.0
    
    private let wordService = WordService()
    private let dataManager = DataManager.shared
    private var gameStats: GameStats
    
    let totalWordsPerGame = 20
    
    init() {
        self.gameSession = GameSession()
        self.gameStats = dataManager.loadGameStats()
        // Try to restore a saved game
        if let saved = dataManager.loadGameState() {
            self.gameSession = saved.gameSession
            self.gameWords = saved.gameWords
            self.currentWordIndex = saved.currentWordIndex
            self.currentWord = (0..<saved.gameWords.count).contains(saved.currentWordIndex) ? saved.gameWords[saved.currentWordIndex] : nil
            self.isGameActive = true
            self.isGameOver = gameSession.isGameOver
            updateProgress()
        }
    }
    
    // MARK: - Game Control
    
    func startNewGame(difficulty: Word.Difficulty? = nil) {
        gameSession = GameSession()
        currentWordIndex = 0
        isGameActive = true
        isGameOver = false
        showFeedback = false
        gameProgress = 0.0
        
        // Generate words for the game
        if let targetDifficulty = difficulty {
            gameWords = wordService.generateGameWords(count: totalWordsPerGame, difficulty: targetDifficulty)
        } else {
            gameWords = wordService.getProgressiveWords(count: totalWordsPerGame)
        }
        

        
        presentNextWord()
        persistState()
    }
    
    func presentNextWord() {
        print("DEBUG: presentNextWord called - currentWordIndex: \(currentWordIndex), gameWords.count: \(gameWords.count), lives: \(gameSession.lives)")
        
        guard currentWordIndex < gameWords.count && gameSession.lives > 0 else {
            print("DEBUG: Game should end! Calling endGame()")
            endGame()
            return
        }
        
        currentWord = gameWords[currentWordIndex]
        wordStartTime = Date()
        updateProgress()
        persistState()
    }
    
    func makeGuess(isReal: Bool) {
        guard let word = currentWord, isGameActive else { return }
        
        let responseTime = Date().timeIntervalSince(wordStartTime)
        let wordResult = WordResult(
            word: word,
            userGuess: isReal,
            responseTime: responseTime,
            timestamp: Date()
        )
        
        gameSession.addWordResult(wordResult)
        
        // Show feedback
        lastAnswerCorrect = wordResult.isCorrect
        showFeedback = true
        
        print("DEBUG: After addWordResult - lives: \(gameSession.lives), currentWordIndex: \(currentWordIndex), totalWordsPerGame: \(totalWordsPerGame)")
        persistState()
        
        // Check if game should end immediately
        if gameSession.lives <= 0 {
            print("DEBUG: Lives = 0, ending game immediately")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.showFeedback = false
                self.endGame()
            }
            return
        }
        
        // Check if all words completed
        if currentWordIndex + 1 >= totalWordsPerGame {
            print("DEBUG: All words completed, ending game")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.showFeedback = false
                self.endGame()
            }
            return
        }
        
        // Move to next word after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.showFeedback = false
            self.currentWordIndex += 1
            self.presentNextWord()
        }
    }
    
    func guessReal() {
        makeGuess(isReal: true)
    }
    
    func guessFake() {
        makeGuess(isReal: false)
    }
    
    private func endGame() {
        print("DEBUG: endGame() called!")
        print("DEBUG: Setting isGameActive = false, isGameOver = true")
        
        isGameActive = false
        isGameOver = true
        gameSession.endGame()
        
        print("DEBUG: isGameOver is now: \(isGameOver)")
        print("DEBUG: isGameActive is now: \(isGameActive)")
        
        // FORCE UI UPDATE
        DispatchQueue.main.async {
            print("DEBUG: Force setting isGameOver = true on main thread")
            self.isGameOver = true
        }
        
        // Update stats
        gameStats.updateWithGameSession(gameSession)
        dataManager.saveGameStats(gameStats)
        
        // Reset word service for next game
        wordService.resetUsedWords()
        // Save final state and clear saved game snapshot (optional keep)
        persistState()
    }
    
    func restartGame() {
        // Reset all game state
        isGameOver = false
        showFeedback = false
        currentWordIndex = 0
        startNewGame()
    }
    
    func returnToHome() {
        isGameActive = false
        isGameOver = false
        currentWord = nil
        gameWords.removeAll()
        currentWordIndex = 0
        persistState()
    }
    
    // MARK: - Progress Tracking
    
    private func updateProgress() {
        gameProgress = Double(currentWordIndex) / Double(totalWordsPerGame)
    }
    
    var remainingWords: Int {
        return totalWordsPerGame - currentWordIndex
    }
    
    var currentScore: Int {
        return gameSession.score
    }
    
    var currentAccuracy: Double {
        return gameSession.accuracy
    }
    
    // MARK: - Game State Helpers
    
    var canUndo: Bool {
        return !gameSession.words.isEmpty && isGameActive
    }
    
    func undoLastGuess() {
        guard canUndo else { return }
        
        // Remove last word result
        gameSession.words.removeLast()
        gameSession.totalWords -= 1
        
        if let lastResult = gameSession.words.last, lastResult.isCorrect {
            gameSession.correctAnswers -= 1
            gameSession.score -= lastResult.points
        }
        
        // Go back to previous word
        currentWordIndex = max(0, currentWordIndex - 1)
        currentWord = gameWords[currentWordIndex]
        wordStartTime = Date()
        updateProgress()
    }
    
    func pauseGame() {
        // Implementation for pause functionality if needed
        isGameActive = false
    }
    
    func resumeGame() {
        isGameActive = true
        wordStartTime = Date() // Reset timer for current word
    }
    
    // MARK: - Statistics
    
    func getGameStats() -> GameStats {
        return gameStats
    }

    // MARK: - Persistence helpers
    private func persistState() {
        let snapshot = SavedGameState(
            gameSession: gameSession,
            gameWords: gameWords,
            currentWordIndex: currentWordIndex
        )
        dataManager.saveGameState(snapshot)
        dataManager.saveGameStats(gameStats)
    }
    
    func resetAllStats() {
        gameStats = GameStats()
        dataManager.saveGameStats(gameStats)
    }
}

// MARK: - Game Difficulty Extension

extension GameViewModel {
    func startEasyGame() {
        startNewGame(difficulty: .easy)
    }
    
    func startMediumGame() {
        startNewGame(difficulty: .medium)
    }
    
    func startHardGame() {
        startNewGame(difficulty: .hard)
    }
    
    func startMixedGame() {
        startNewGame(difficulty: nil)
    }
}

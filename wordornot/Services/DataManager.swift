//
//  DataManager.swift
//  wordornot
//
//  Created by mustafa ergisi on 8/10/25.
//

import Foundation

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    private let documentsDirectory: URL
    private let statsFileName = "gameStats.json"
    private let wordsFileName = "words.json"
    private let savedGameFileName = "savedGame.json"
    private let seenWordsFileName = "seenWords.json"
    
    private init() {
        documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    // MARK: - Game Stats Management
    
    func loadGameStats() -> GameStats {
        let statsURL = documentsDirectory.appendingPathComponent(statsFileName)
        
        guard FileManager.default.fileExists(atPath: statsURL.path) else {
            return GameStats()
        }
        
        do {
            let data = try Data(contentsOf: statsURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let stats = try decoder.decode(GameStats.self, from: data)
            return stats
        } catch {
            print("Failed to load game stats: \(error)")
            return GameStats()
        }
    }
    
    func saveGameStats(_ stats: GameStats) {
        let statsURL = documentsDirectory.appendingPathComponent(statsFileName)
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(stats)
            try data.write(to: statsURL)
        } catch {
            print("Failed to save game stats: \(error)")
        }
    }
    
    // MARK: - Words Management
    
    func loadWords() -> [Word] {
        // First try to load from documents directory (user's custom words)
        let wordsURL = documentsDirectory.appendingPathComponent(wordsFileName)
        
        if FileManager.default.fileExists(atPath: wordsURL.path) {
            do {
                let data = try Data(contentsOf: wordsURL)
                let words = try JSONDecoder().decode([Word].self, from: data)
                return words
            } catch {
                print("Failed to load words from documents: \(error)")
            }
        }
        
        // Fallback to bundle words if no custom words exist
        return loadDefaultWords()
    }
    
    // MARK: - Saved Game Management
    func saveGameState(_ state: SavedGameState) {
        let url = documentsDirectory.appendingPathComponent(savedGameFileName)
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(state)
            try data.write(to: url)
        } catch {
            print("Failed to save game state: \(error)")
        }
    }

    func loadGameState() -> SavedGameState? {
        let url = documentsDirectory.appendingPathComponent(savedGameFileName)
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let data = try Data(contentsOf: url)
            return try decoder.decode(SavedGameState.self, from: data)
        } catch {
            print("Failed to load game state: \(error)")
            return nil
        }
    }

    func clearSavedGame() {
        let url = documentsDirectory.appendingPathComponent(savedGameFileName)
        try? FileManager.default.removeItem(at: url)
    }

    private func loadDefaultWords() -> [Word] {
        guard let bundleURL = Bundle.main.url(forResource: wordsFileName.replacingOccurrences(of: ".json", with: ""), withExtension: "json") else {
            print("DEBUG: Default words file not found in bundle")
            return createFallbackWords()
        }
        
        do {
            let data = try Data(contentsOf: bundleURL)
            let words = try JSONDecoder().decode([Word].self, from: data)
            print("DEBUG: Loaded \(words.count) words from bundle")
            return words
        } catch {
            print("DEBUG: Failed to load default words: \(error)")
            return createFallbackWords()
        }
    }
    
    func saveWords(_ words: [Word]) {
        let wordsURL = documentsDirectory.appendingPathComponent(wordsFileName)
        
        do {
            let data = try JSONEncoder().encode(words)
            try data.write(to: wordsURL)
        } catch {
            print("Failed to save words: \(error)")
        }
    }
    
    // MARK: - Fallback Words
    
    private func createFallbackWords() -> [Word] {
        return [
            // Real words - Easy
            Word(text: "happy", isReal: true, difficulty: .easy, category: .common),
            Word(text: "water", isReal: true, difficulty: .easy, category: .common),
            Word(text: "house", isReal: true, difficulty: .easy, category: .common),
            Word(text: "phone", isReal: true, difficulty: .easy, category: .common),
            Word(text: "music", isReal: true, difficulty: .easy, category: .common),
            
            // Real words - Medium
            Word(text: "abundant", isReal: true, difficulty: .medium, category: .common),
            Word(text: "eloquent", isReal: true, difficulty: .medium, category: .common),
            Word(text: "precise", isReal: true, difficulty: .medium, category: .common),
            Word(text: "vibrant", isReal: true, difficulty: .medium, category: .common),
            Word(text: "dynamic", isReal: true, difficulty: .medium, category: .common),
            
            // Real words - Hard
            Word(text: "perspicacious", isReal: true, difficulty: .hard, category: .archaic),
            Word(text: "sesquipedalian", isReal: true, difficulty: .hard, category: .technical),
            Word(text: "antediluvian", isReal: true, difficulty: .hard, category: .archaic),
            Word(text: "grandiloquent", isReal: true, difficulty: .hard, category: .archaic),
            Word(text: "pusillanimous", isReal: true, difficulty: .hard, category: .archaic),
            
            // Fake words - Easy
            Word(text: "flurble", isReal: false, difficulty: .easy, category: .invented),
            Word(text: "wobbit", isReal: false, difficulty: .easy, category: .invented),
            Word(text: "snurgle", isReal: false, difficulty: .easy, category: .invented),
            Word(text: "blimple", isReal: false, difficulty: .easy, category: .invented),
            Word(text: "krangle", isReal: false, difficulty: .easy, category: .invented),
            
            // Fake words - Medium
            Word(text: "flimbulent", isReal: false, difficulty: .medium, category: .invented),
            Word(text: "grompulent", isReal: false, difficulty: .medium, category: .invented),
            Word(text: "snurdlicious", isReal: false, difficulty: .medium, category: .invented),
            Word(text: "blimperous", isReal: false, difficulty: .medium, category: .invented),
            Word(text: "kringletons", isReal: false, difficulty: .medium, category: .invented),
            
            // Fake words - Hard
            Word(text: "flimbulentious", isReal: false, difficulty: .hard, category: .invented),
            Word(text: "grompulentific", isReal: false, difficulty: .hard, category: .invented),
            Word(text: "snurdliciously", isReal: false, difficulty: .hard, category: .invented),
            Word(text: "blimperousness", isReal: false, difficulty: .hard, category: .invented),
            Word(text: "kringletonian", isReal: false, difficulty: .hard, category: .invented)
        ]
    }
    
    // MARK: - File System Utilities
    
    func clearAllData() {
        let statsURL = documentsDirectory.appendingPathComponent(statsFileName)
        let wordsURL = documentsDirectory.appendingPathComponent(wordsFileName)
        let seenURL = documentsDirectory.appendingPathComponent(seenWordsFileName)
        
        try? FileManager.default.removeItem(at: statsURL)
        try? FileManager.default.removeItem(at: wordsURL)
        try? FileManager.default.removeItem(at: seenURL)
    }
    
    func exportData() -> Data? {
        let stats = loadGameStats()
        let words = loadWords()
        
        let exportData = ExportData(stats: stats, words: words)
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            return try encoder.encode(exportData)
        } catch {
            print("Failed to export data: \(error)")
            return nil
        }
    }

    // MARK: - Seen words persistence
    func loadSeenWords() -> Set<String> {
        let url = documentsDirectory.appendingPathComponent(seenWordsFileName)
        guard FileManager.default.fileExists(atPath: url.path) else { return [] }
        do {
            let data = try Data(contentsOf: url)
            let container = try JSONDecoder().decode(PersistentSeenWords.self, from: data)
            return container.seen
        } catch {
            print("Failed to load seen words: \(error)")
            return []
        }
    }
    
    func saveSeenWords(_ seen: Set<String>) {
        let url = documentsDirectory.appendingPathComponent(seenWordsFileName)
        do {
            let data = try JSONEncoder().encode(PersistentSeenWords(seen: seen))
            try data.write(to: url)
        } catch {
            print("Failed to save seen words: \(error)")
        }
    }
    
    func importData(_ data: Data) -> Bool {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let exportData = try decoder.decode(ExportData.self, from: data)
            
            saveGameStats(exportData.stats)
            saveWords(exportData.words)
            
            return true
        } catch {
            print("Failed to import data: \(error)")
            return false
        }
    }
}

// MARK: - Supporting Types

private struct ExportData: Codable {
    let stats: GameStats
    let words: [Word]
}

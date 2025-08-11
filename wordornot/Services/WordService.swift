//
//  WordService.swift
//  wordornot
//
//  Created by mustafa ergisi on 8/10/25.
//

import Foundation

class WordService: ObservableObject {
    private let dataManager = DataManager.shared
    private var allWords: [Word] = []
    private var usedWords: Set<String> = []
    private var seenWords: Set<String> = [] // persisted across sessions
    
    init() {
        loadWords()
        seenWords = dataManager.loadSeenWords()
    }
    
    func loadWords() {
        allWords = dataManager.loadWords()
    }
    
    func getRandomWord(excluding difficulty: Word.Difficulty? = nil) -> Word? {
        var availableWords = allWords.filter { word in
            !usedWords.contains(word.text) && !seenWords.contains(word.text)
        }
        
        if let excludedDifficulty = difficulty {
            availableWords = availableWords.filter { $0.difficulty != excludedDifficulty }
        }
        
        guard !availableWords.isEmpty else {
            // Reset used words if all have been used
            resetUsedWords()
            availableWords = allWords.filter { !seenWords.contains($0.text) }
            return availableWords.randomElement()
        }
        
        return availableWords.randomElement()
    }
    
    func getRandomWord(difficulty: Word.Difficulty) -> Word? {
        var availableWords = allWords.filter { word in
            word.difficulty == difficulty && !usedWords.contains(word.text) && !seenWords.contains(word.text)
        }
        
        guard !availableWords.isEmpty else {
            // Reset used words for this difficulty if all have been used
            let usedWordsForDifficulty = usedWords.filter { usedWord in
                allWords.contains { $0.text == usedWord && $0.difficulty == difficulty }
            }
            
            if usedWordsForDifficulty.count >= allWords.filter({ $0.difficulty == difficulty }).count {
                resetUsedWords()
                availableWords = allWords.filter { $0.difficulty == difficulty && !seenWords.contains($0.text) }
                return availableWords.randomElement()
            } else {
                return nil
            }
        }
        
        return availableWords.randomElement()
    }
    
    func getRandomWords(count: Int, balanceRealFake: Bool = true) -> [Word] {
        var selectedWords: [Word] = []
        
        if balanceRealFake {
            let realCount = count / 2
            let fakeCount = count - realCount
            
            // Get real words
            for _ in 0..<realCount {
                if let word = getRandomWord(isReal: true) {
                    selectedWords.append(word)
                    markWordAsUsed(word)
                }
            }
            
            // Get fake words
            for _ in 0..<fakeCount {
                if let word = getRandomWord(isReal: false) {
                    selectedWords.append(word)
                    markWordAsUsed(word)
                }
            }
        } else {
            for _ in 0..<count {
                if let word = getRandomWord() {
                    selectedWords.append(word)
                    markWordAsUsed(word)
                }
            }
        }
        
        return selectedWords.shuffled()
    }
    
    private func getRandomWord(isReal: Bool) -> Word? {
        let availableWords = allWords.filter { word in
            word.isReal == isReal && !usedWords.contains(word.text) && !seenWords.contains(word.text)
        }
        
        return availableWords.randomElement()
    }
    
    func markWordAsUsed(_ word: Word) {
        usedWords.insert(word.text)
        seenWords.insert(word.text)
        dataManager.saveSeenWords(seenWords)
    }
    
    func resetUsedWords() {
        usedWords.removeAll()
    }
    
    func getWordsCount() -> Int {
        return allWords.count
    }
    
    func getWordsCount(difficulty: Word.Difficulty) -> Int {
        return allWords.filter { $0.difficulty == difficulty }.count
    }
    
    func getWordsCount(isReal: Bool) -> Int {
        return allWords.filter { $0.isReal == isReal }.count
    }
    
    func getWordsCount(category: Word.WordCategory) -> Int {
        return allWords.filter { $0.category == category }.count
    }
    
    func getWordsByDifficulty() -> [Word.Difficulty: [Word]] {
        return Dictionary(grouping: allWords, by: { $0.difficulty })
    }
    
    func getWordsByCategory() -> [Word.WordCategory: [Word]] {
        return Dictionary(grouping: allWords, by: { $0.category })
    }
    
    func searchWords(query: String) -> [Word] {
        guard !query.isEmpty else { return allWords }
        
        return allWords.filter { word in
            word.text.lowercased().contains(query.lowercased())
        }
    }
    
    func addCustomWord(_ word: Word) {
        allWords.append(word)
        dataManager.saveWords(allWords)
    }
    
    func removeWord(_ word: Word) {
        allWords.removeAll { $0.text == word.text }
        dataManager.saveWords(allWords)
    }
    
    func resetToDefaultWords() {
        dataManager.clearAllData()
        loadWords()
        resetUsedWords()
    }
    
    // MARK: - Game Session Helpers
    
    func generateGameWords(count: Int = 20, difficulty: Word.Difficulty? = nil) -> [Word] {
        var gameWords: [Word] = []
        
        for _ in 0..<count {
            let word: Word?
            
            if let targetDifficulty = difficulty {
                word = getRandomWord(difficulty: targetDifficulty)
            } else {
                word = getRandomWord()
            }
            
            if let selectedWord = word {
                gameWords.append(selectedWord)
                markWordAsUsed(selectedWord)
            }
        }
        
        return gameWords.shuffled()
    }
    
    func getProgressiveWords(startingDifficulty: Word.Difficulty = .easy, count: Int = 20) -> [Word] {
        var gameWords: [Word] = []
        
        let wordsPerDifficulty = count / 3
        
        // Easy words
        for _ in 0..<wordsPerDifficulty {
            if let word = getRandomWord(difficulty: .easy) {
                gameWords.append(word)
                markWordAsUsed(word)
            }
        }
        
        // Medium words
        for _ in 0..<wordsPerDifficulty {
            if let word = getRandomWord(difficulty: .medium) {
                gameWords.append(word)
                markWordAsUsed(word)
            }
        }
        
        // Hard words for remaining
        let remainingCount = count - (wordsPerDifficulty * 2)
        for _ in 0..<remainingCount {
            if let word = getRandomWord(difficulty: .hard) {
                gameWords.append(word)
                markWordAsUsed(word)
            }
        }
        
        return gameWords.shuffled()
    }
}

//
//  Word.swift
//  wordornot
//
//  Created by mustafa ergisi on 8/10/25.
//

import Foundation

struct Word: Codable, Identifiable, Hashable {
    let id = UUID()
    let text: String
    let isReal: Bool
    let difficulty: Difficulty
    let category: WordCategory
    
    enum Difficulty: String, CaseIterable, Codable {
        case easy = "easy"
        case medium = "medium"
        case hard = "hard"
        
        var displayName: String {
            return rawValue.capitalized
        }
    }
    
    enum WordCategory: String, CaseIterable, Codable {
        case common = "common"
        case technical = "technical"
        case archaic = "archaic"
        case scientific = "scientific"
        case invented = "invented"
        
        var displayName: String {
            return rawValue.capitalized
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case text, isReal, difficulty, category
    }
}

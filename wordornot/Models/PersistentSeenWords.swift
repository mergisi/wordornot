//
//  PersistentSeenWords.swift
//  wordornot
//
//  Created by mustafa ergisi on 8/10/25.
//

import Foundation

struct PersistentSeenWords: Codable {
    var seen: Set<String>
    
    init(seen: Set<String> = []) {
        self.seen = seen
    }
}



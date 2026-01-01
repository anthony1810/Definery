//
//  TestHelpers.swift
//  Definery
//
//  Created by Anthony on 1/1/26.
//

import Foundation
import WordFeature

@testable import WordCache

protocol WordCacheProtocol {
    func deleteCachedWords() async throws
    func insertCache(words: [Word]) async throws
}

struct LocalWordLoader {
    let cache: WordCacheProtocol
    
    func save(_ words: [Word]) async throws {
        try await cache.deleteCachedWords()
        try await cache.insertCache(words: words)
    }
}

func anyNSError() -> NSError {
    NSError(domain: "any", code: 0)
}

func uniqueWord() -> Word {
    Word(id: UUID(), text: "word-\(UUID())", language: "en", phonetic: nil, meanings: [])
}

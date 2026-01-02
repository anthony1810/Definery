//
//  WordCacheSpy.swift
//  DefineryTests
//
//  Created by Anthony on 2/1/26.
//

import Foundation
import WordFeature

final class WordCacheSpy: WordCacheProtocol, @unchecked Sendable {
    private(set) var savedWords: [Word] = []

    func save(_ words: [Word]) async throws {
        savedWords.append(contentsOf: words)
    }
}

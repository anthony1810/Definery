//
//  LocalWordLoader.swift
//  WordCache
//
//  Created by Anthony on 1/1/26.
//

import Foundation
import WordFeature

public struct LocalWordLoader {
    private let cache: WordCacheProtocol

    public init(cache: WordCacheProtocol) {
        self.cache = cache
    }

    public func save(_ words: [Word]) async throws {
        try await cache.deleteCachedWords()
        try await cache.insertCache(words: words)
    }

    public func load() async throws -> [Word] {
        try await cache.retrieveWords()
    }
}

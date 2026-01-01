//
//  LocalWordLoader.swift
//  WordCache
//
//  Created by Anthony on 1/1/26.
//

import Foundation
import WordFeature

public struct LocalWordLoader: WordCacheProtocol {
    private let store: WordStorageProtocol

    public init(store: WordStorageProtocol) {
        self.store = store
    }

    public func save(_ words: [Word]) async throws {
        try await store.deleteCachedWords()
        try await store.insertCache(words: words)
    }

    public func load() async throws -> [Word] {
        try await store.retrieveWords()
    }
}

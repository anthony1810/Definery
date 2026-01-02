//
//  RemoteWithLocalFallbackLoader.swift
//  Definery
//
//  Created by Anthony on 2/1/26.
//

import Foundation
import WordFeature

final class RemoteWithLocalFallbackLoader: WordLoaderProtocol {
    private let remote: WordLoaderProtocol
    private let local: WordLoaderProtocol
    private let cache: WordCacheProtocol

    init(remote: WordLoaderProtocol, local: WordLoaderProtocol, cache: WordCacheProtocol) {
        self.remote = remote
        self.local = local
        self.cache = cache
    }

    func load() async throws -> [Word] {
        let words = try await remote.load()
        try? await cache.save(words)
        
        return words
    }
}

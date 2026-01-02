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
        try await store.insertCache(words: words.map { $0.toLocal() })
    }

    public func load() async throws -> [Word] {
        try await store.retrieveWords().map { $0.toModel() }
    }
}

// MARK: - Mapping

private extension Word {
    func toLocal() -> LocalWord {
        LocalWord(
            id: id,
            text: text,
            language: language,
            phonetic: phonetic,
            meanings: meanings.map { $0.toLocal() }
        )
    }
}

private extension Meaning {
    func toLocal() -> LocalMeaning {
        LocalMeaning(
            partOfSpeech: partOfSpeech,
            definition: definition,
            example: example
        )
    }
}

private extension LocalWord {
    func toModel() -> Word {
        Word(
            id: id,
            text: text,
            language: language,
            phonetic: phonetic,
            meanings: meanings.map { $0.toModel() }
        )
    }
}

private extension LocalMeaning {
    func toModel() -> Meaning {
        Meaning(
            partOfSpeech: partOfSpeech,
            definition: definition,
            example: example
        )
    }
}

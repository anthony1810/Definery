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
    func retrieveWords() async throws -> [Word]
}

struct LocalWordLoader {
    let cache: WordCacheProtocol
    
    func save(_ words: [Word]) async throws {
        try await cache.deleteCachedWords()
        try await cache.insertCache(words: words)
    }
    
    func load() async throws -> [Word] {
        try await cache.retrieveWords()
    }
}

final class WordCacheSpy: WordCacheProtocol, @unchecked Sendable {
    
    enum ReceiveMessage: Equatable {
        case deletion
        case insertion(_ words: [Word])
        case retrieve
    }
    
    var receiveMessages: [ReceiveMessage] = []
    
    // MARK: - Deletion
    private var deletionResult: Result<Void, Error>?
    func deleteCachedWords() async throws {
        receiveMessages.append(.deletion)
        
        return try deletionResult.evaluate()
    }
    
    func completeDeletion(with result: Result<Void, Error>) {
        self.deletionResult = result
    }
    
    // MARK: - Insertion
    private var insertionResult: Result<Void, Error>?
    func insertCache(words: [Word]) async throws {
        receiveMessages.append(.insertion(words))
        try insertionResult.evaluate()
    }
    
    func completeInsertion(with result: Result<Void, Error>) {
        insertionResult = result
    }
    
    // MARK: - Retrieve
    private var retrievalResult: Result<[Word], Error>?
    func retrieveWords() async throws -> [Word] {
        receiveMessages.append(.retrieve)
        return try retrievalResult.evaluate()
    }
    
    func completeRetrieval(with result: Result<[Word], Error>) {
        retrievalResult = result
    }
}


func anyNSError() -> NSError {
    NSError(domain: "any", code: 0)
}

func uniqueWord() -> Word {
    Word(id: UUID(), text: "word-\(UUID())", language: "en", phonetic: nil, meanings: [])
}

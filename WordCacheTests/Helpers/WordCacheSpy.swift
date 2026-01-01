//
//  WordCacheSpy.swift
//  WordCacheTests
//
//  Created by Anthony on 1/1/26.
//

import Foundation
import WordFeature
import WordCache

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
        try deletionResult.evaluate()
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

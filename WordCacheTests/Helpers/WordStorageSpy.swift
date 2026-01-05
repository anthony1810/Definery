//
//  WordStorageSpy.swift
//  WordCacheTests
//
//  Created by Anthony on 1/1/26.
//

import Foundation
import WordCache

final class WordStorageSpy: WordStorageProtocol, @unchecked Sendable {

    enum ReceiveMessage: Equatable {
        case deletion
        case insertion(_ words: [LocalWord])
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
    func insertCache(words: [LocalWord]) async throws {
        receiveMessages.append(.insertion(words))
        try insertionResult.evaluate()
    }

    func completeInsertion(with result: Result<Void, Error>) {
        insertionResult = result
    }

    // MARK: - Retrieve
    private var retrievalResult: Result<[LocalWord], Error>?
    func retrieveWords() async throws -> [LocalWord] {
        receiveMessages.append(.retrieve)
        return try retrievalResult.evaluate()
    }

    func completeRetrieval(with result: Result<[LocalWord], Error>) {
        retrievalResult = result
    }
}

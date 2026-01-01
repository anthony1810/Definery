//
//  WordCacheTests.swift
//  WordCacheTests
//
//  Created by Anthony on 1/1/26.
//

import Foundation
import Testing
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

struct CacheWordUseCaseTests {
    
    @Test func init_doesNotMessageCacheUponCreation() {
        let (_, cacheSpy) = makeSUT()
        
        #expect(cacheSpy.receiveMessages == [])
    }
    
    @Test func save_requestsCacheDeletion() async throws {
        let (sut, cacheSpy) = makeSUT()
        
        cacheSpy.completeDeletion(with: .success(()))
        cacheSpy.completeInsertion(with: .success(()))
        try? await sut.save([])
        
        #expect(cacheSpy.receiveMessages[0] == .deletion)
    }
    
    @Test func save_doesNotInsertCacheOnDeletionError() async {
        let (sut, cacheSpy) = makeSUT()
        let deletionError = anyNSError()
        
        cacheSpy.completeDeletion(with: .failure(deletionError))
        try? await sut.save([])
        
        #expect(cacheSpy.receiveMessages == [.deletion]) // no insertion signal
    }
    
    @Test func save_failsOnDeletionFailure() async throws {
        let (sut, cacheSpy) = makeSUT()
        let deletionError = anyNSError()
        
        cacheSpy.completeDeletion(with: .failure(deletionError))
        do {
            try await sut.save([])
            Issue.record("Expected to throw, but it succeeded")
        } catch {
            #expect(error as NSError? == deletionError)
        }
    }
    
    @Test func save_failsOnInsertionFailure() async throws {
        let (sut, cacheSpy) = makeSUT()
        let insertionError = anyNSError()
        
        cacheSpy.completeDeletion(with: .success(()))
        cacheSpy.completeInsertion(with: .failure(insertionError))
        do {
            try await sut.save([])
            Issue.record("Expected to throw, but it succeeded")
        } catch {
            #expect(error as NSError? == insertionError)
        }
    }
    
    @Test func save_requestCacheInsertionWithWordsOnDeletionSuccess() async throws {
        let (sut, cacheSpy) = makeSUT()
        let words = [uniqueWord(), uniqueWord()]
        
        cacheSpy.completeDeletion(with: .success(()))
        cacheSpy.completeInsertion(with: .success(()))
        try await sut.save(words)
        
        #expect(cacheSpy.receiveMessages == [.deletion, .insertion(words)])
    }
    
    // MARK: - Helpers
    private func makeSUT() -> (sut: LocalWordLoader, cache: WordCacheSpy) {
        let cache = WordCacheSpy()
        let sut = LocalWordLoader(cache: cache)
        return (sut: sut, cache: cache)
    }
    
    final class WordCacheSpy: WordCacheProtocol, @unchecked Sendable {
        
        enum ReceiveMessage: Equatable {
            case deletion
            case insertion(_ words: [Word])
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
    }
}

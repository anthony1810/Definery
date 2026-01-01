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

struct CacheWordUseCaseTests {
    
    @Test func init_doesNotMessageCacheUponCreation() {
        let (_, store) = makeSUT()
        
        #expect(store.receiveMessages == [])
    }
    
    @Test func save_requestsCacheDeletion() async throws {
        let (sut, store) = makeSUT()
        
        store.completeDeletion(with: .success(()))
        store.completeInsertion(with: .success(()))
        try? await sut.save([])
        
        #expect(store.receiveMessages[0] == .deletion)
    }
    
    @Test func save_doesNotInsertCacheOnDeletionError() async {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        store.completeDeletion(with: .failure(deletionError))
        try? await sut.save([])
        
        #expect(store.receiveMessages == [.deletion]) // no insertion signal
    }
    
    @Test func save_failsOnDeletionFailure() async throws {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        store.completeDeletion(with: .failure(deletionError))
        do {
            try await sut.save([])
            Issue.record("Expected to throw, but it succeeded")
        } catch {
            #expect(error as NSError? == deletionError)
        }
    }
    
    @Test func save_failsOnInsertionFailure() async throws {
        let (sut, store) = makeSUT()
        let insertionError = anyNSError()
        
        store.completeDeletion(with: .success(()))
        store.completeInsertion(with: .failure(insertionError))
        do {
            try await sut.save([])
            Issue.record("Expected to throw, but it succeeded")
        } catch {
            #expect(error as NSError? == insertionError)
        }
    }
    
    @Test func save_requestCacheInsertionWithWordsOnDeletionSuccess() async throws {
        let (sut, store) = makeSUT()
        let words = [uniqueWord(), uniqueWord()]
        
        store.completeDeletion(with: .success(()))
        store.completeInsertion(with: .success(()))
        try await sut.save(words)
        
        #expect(store.receiveMessages == [.deletion, .insertion(words)])
    }
    
    // MARK: - Helpers
    private func makeSUT() -> (sut: LocalWordLoader, store: WordStorageSpy) {
        let store = WordStorageSpy()
        let sut = LocalWordLoader(store: store)
        return (sut: sut, store: store)
    }
}

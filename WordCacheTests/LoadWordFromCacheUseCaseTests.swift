//
//  LoadWordFromCacheUseCaseTests.swift
//  WordCacheTests
//
//  Created by Anthony on 1/1/26.
//

import Foundation
import Testing
import WordFeature

@testable import WordCache

struct LoadWordFromCacheUseCaseTests {

    @Test func load_requestsCacheRetrieval() async {
        let (sut, store) = makeSUT()
        
        store.completeRetrieval(with: .success([]))
        _ = try? await sut.load()
        
        #expect(store.receiveMessages == [.retrieve])
    }

    @Test func load_failsOnRetrievalError() async {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        
        store.completeRetrieval(with: .failure(retrievalError))
        do {
            _ = try await sut.load()
            Issue.record("Expect to throw, but succeeded")
        } catch {
            #expect(error as NSError? == retrievalError)
        }
    }

    @Test func load_deliversNoWordsOnEmptyCache() async throws {
        let (sut, store) = makeSUT()
        
        store.completeRetrieval(with: .success([]))
        let result = try await sut.load()
        
        #expect(result.isEmpty)
    }

    @Test func load_deliversCachedWords() async throws {
        let (sut, store) = makeSUT()
        let expectedWords: [Word] = [uniqueWord(), uniqueWord()]
        
        store.completeRetrieval(with: .success(expectedWords))
        let actualResults = try await sut.load()
        
        #expect(actualResults == expectedWords)
    }

    @Test func load_hasNoSideEffectOnRetrievalError() async {
        let (sut, store) = makeSUT()
        
        store.completeRetrieval(with: .failure(anyNSError()))
        let _ = try? await sut.load()
        
        #expect(store.receiveMessages == [.retrieve])
    }

    @Test func load_hasNoSideEffectOnEmptyCache() async {
        let (sut, store) = makeSUT()
        
        store.completeRetrieval(with: .success([]))
        let _ = try? await sut.load()
        
        #expect(store.receiveMessages == [.retrieve])
    }

    @Test func load_hasNoSideEffectOnNonEmptyCache() async {
        let (sut, store) = makeSUT()
        
        store.completeRetrieval(with: .success([uniqueWord()]))
        let _ = try? await sut.load()
        
        #expect(store.receiveMessages == [.retrieve])
    }
    
    // MARK: - Helpers
    private func makeSUT() -> (sut: LocalWordLoader, store: WordStorageSpy) {
        let store = WordStorageSpy()
        let sut = LocalWordLoader(store: store)
        return (sut: sut, store: store)
    }
}

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
        let (sut, cache) = makeSUT()
        
        cache.completeRetrieval(with: .success([]))
        _ = try? await sut.load()
        
        #expect(cache.receiveMessages == [.retrieve])
    }

    @Test func load_failsOnRetrievalError() async {
        let (sut, cache) = makeSUT()
        let retrievalError = anyNSError()
        
        cache.completeRetrieval(with: .failure(retrievalError))
        do {
            _ = try await sut.load()
            Issue.record("Expect to throw, but succeeded")
        } catch {
            #expect(error as NSError? == retrievalError)
        }
    }

    @Test func load_deliversNoWordsOnEmptyCache() async throws {
        let (sut, cache) = makeSUT()
        
        cache.completeRetrieval(with: .success([]))
        let result = try await sut.load()
        
        #expect(result.isEmpty)
    }

//    @Test func load_deliversCachedWords() async {}

//    @Test func load_hasNoSideEffectOnRetrievalError() async {}

//    @Test func load_hasNoSideEffectOnEmptyCache() async {}

//    @Test func load_hasNoSideEffectOnNonEmptyCache() async {}
    
    // MARK: - Helpers
    private func makeSUT() -> (sut: LocalWordLoader, cache: WordCacheSpy) {
        let cache = WordCacheSpy()
        let sut = LocalWordLoader(cache: cache)
        return (sut: sut, cache: cache)
    }
}

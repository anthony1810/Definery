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

final class LoadWordFromCacheUseCaseTests {
    private var leakTrackers: [MemoryLeakTracker] = []

    deinit {
        leakTrackers.forEach { $0.verify() }
    }

    @Test func load_requestsCacheRetrieval() async {
        let sut = makeSUT()

        sut.store.completeRetrieval(with: .success([]))
        _ = try? await sut.loader.load()

        #expect(sut.store.receiveMessages == [.retrieve])
    }

    @Test func load_failsOnRetrievalError() async {
        let sut = makeSUT()
        let retrievalError = anyNSError()

        sut.store.completeRetrieval(with: .failure(retrievalError))
        do {
            _ = try await sut.loader.load()
            Issue.record("Expect to throw, but succeeded")
        } catch {
            #expect(error as NSError? == retrievalError)
        }
    }

    @Test func load_deliversNoWordsOnEmptyCache() async throws {
        let sut = makeSUT()

        sut.store.completeRetrieval(with: .success([]))
        let result = try await sut.loader.load()

        #expect(result.isEmpty)
    }

    @Test func load_deliversCachedWords() async throws {
        let sut = makeSUT()
        let (expectedWords, localWords) = uniqueWords()

        sut.store.completeRetrieval(with: .success(localWords))
        let actualResults = try await sut.loader.load()

        #expect(actualResults == expectedWords)
    }

    @Test func load_hasNoSideEffectOnRetrievalError() async {
        let sut = makeSUT()

        sut.store.completeRetrieval(with: .failure(anyNSError()))
        _ = try? await sut.loader.load()

        #expect(sut.store.receiveMessages == [.retrieve])
    }

    @Test func load_hasNoSideEffectOnEmptyCache() async {
        let sut = makeSUT()

        sut.store.completeRetrieval(with: .success([]))
        _ = try? await sut.loader.load()

        #expect(sut.store.receiveMessages == [.retrieve])
    }

    @Test func load_hasNoSideEffectOnNonEmptyCache() async {
        let sut = makeSUT()

        sut.store.completeRetrieval(with: .success([uniqueLocalWord()]))
        _ = try? await sut.loader.load()

        #expect(sut.store.receiveMessages == [.retrieve])
    }
}

// MARK: - Helpers

extension LoadWordFromCacheUseCaseTests {
    private func trackForMemoryLeaks(
        _ instance: AnyObject,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        leakTrackers.append(MemoryLeakTracker(instance: instance, sourceLocation: sourceLocation))
    }

    private func makeSUT(
        sourceLocation: SourceLocation = #_sourceLocation
    ) -> (loader: LocalWordLoader, store: WordStorageSpy) {
        let store = WordStorageSpy()
        let loader = LocalWordLoader(store: store)
        trackForMemoryLeaks(store, sourceLocation: sourceLocation)
        return (loader, store)
    }
}

//
//  CacheWordUseCaseTests.swift
//  WordCacheTests
//
//  Created by Anthony on 1/1/26.
//

import Foundation
import Testing
import WordFeature

@testable import WordCache

final class CacheWordUseCaseTests {
    private var leakTrackers: [MemoryLeakTracker] = []

    deinit {
        leakTrackers.forEach { $0.verify() }
    }

    @Test func init_doesNotMessageCacheUponCreation() {
        let sut = makeSUT()

        #expect(sut.store.receiveMessages == [])
    }

    @Test func save_requestsCacheDeletion() async throws {
        let sut = makeSUT()

        sut.store.completeDeletion(with: .success(()))
        sut.store.completeInsertion(with: .success(()))
        try? await sut.loader.save([])

        #expect(sut.store.receiveMessages[0] == .deletion)
    }

    @Test func save_doesNotInsertCacheOnDeletionError() async {
        let sut = makeSUT()
        let deletionError = anyNSError()

        sut.store.completeDeletion(with: .failure(deletionError))
        try? await sut.loader.save([])

        #expect(sut.store.receiveMessages == [.deletion])
    }

    @Test func save_failsOnDeletionFailure() async throws {
        let sut = makeSUT()
        let deletionError = anyNSError()

        sut.store.completeDeletion(with: .failure(deletionError))
        do {
            try await sut.loader.save([])
            Issue.record("Expected to throw, but it succeeded")
        } catch {
            #expect(error as NSError? == deletionError)
        }
    }

    @Test func save_failsOnInsertionFailure() async throws {
        let sut = makeSUT()
        let insertionError = anyNSError()

        sut.store.completeDeletion(with: .success(()))
        sut.store.completeInsertion(with: .failure(insertionError))
        do {
            try await sut.loader.save([])
            Issue.record("Expected to throw, but it succeeded")
        } catch {
            #expect(error as NSError? == insertionError)
        }
    }

    @Test func save_requestCacheInsertionWithWordsOnDeletionSuccess() async throws {
        let sut = makeSUT()
        let (words, localWords) = uniqueWords()

        sut.store.completeDeletion(with: .success(()))
        sut.store.completeInsertion(with: .success(()))
        try await sut.loader.save(words)

        #expect(sut.store.receiveMessages == [.deletion, .insertion(localWords)])
    }
}

// MARK: - Helpers

extension CacheWordUseCaseTests {
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

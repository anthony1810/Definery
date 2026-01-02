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
    private var sutTracker: MemoryLeakTracker<SUT>?

    deinit {
        sutTracker?.verify()
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
    final class SUT {
        let loader: LocalWordLoader
        let store: WordStorageSpy

        init(loader: LocalWordLoader, store: WordStorageSpy) {
            self.loader = loader
            self.store = store
        }
    }

    private func makeSUT(
        fileId: String = #fileID,
        filePath: String = #filePath,
        line: Int = #line,
        column: Int = #column
    ) -> SUT {
        let store = WordStorageSpy()
        let loader = LocalWordLoader(store: store)
        let sut = SUT(loader: loader, store: store)

        sutTracker = MemoryLeakTracker(
            instance: sut,
            sourceLocation: SourceLocation(
                fileID: fileId,
                filePath: filePath,
                line: line,
                column: column
            )
        )

        return sut
    }
}

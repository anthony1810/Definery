//
//  RemoteWithLocalFallbackLoaderTests.swift
//  DefineryTests
//
//  Created by Anthony on 2/1/26.
//

import Testing

@testable import Definery

final class RemoteWithLocalFallbackLoaderTests {
    private var sutTracker: MemoryLeakTracker<RemoteWithLocalFallbackLoader>?

    deinit {
        sutTracker?.verify()
    }

    @Test func load_deliversRemoteWordsOnRemoteSuccess() async throws {
        let sut = makeSUT()
        let remoteWords = [uniqueWord()]

        sut.remote.complete(with: .success(remoteWords))

        let result = try await sut.loader.load()

        #expect(result == remoteWords)
    }
}

// MARK: - Helpers

extension RemoteWithLocalFallbackLoaderTests {
    private struct SUT {
        let loader: RemoteWithLocalFallbackLoader
        let remote: WordLoaderSpy
        let local: WordLoaderSpy
        let cache: WordCacheSpy
    }

    private func makeSUT(
        fileId: String = #fileID,
        filePath: String = #filePath,
        line: Int = #line,
        column: Int = #column
    ) -> SUT {
        let remote = WordLoaderSpy()
        let local = WordLoaderSpy()
        let cache = WordCacheSpy()
        let sut = RemoteWithLocalFallbackLoader(remote: remote, local: local, cache: cache)

        sutTracker = MemoryLeakTracker(
            instance: sut,
            sourceLocation: SourceLocation(
                fileID: fileId,
                filePath: filePath,
                line: line,
                column: column
            )
        )

        return SUT(loader: sut, remote: remote, local: local, cache: cache)
    }
}

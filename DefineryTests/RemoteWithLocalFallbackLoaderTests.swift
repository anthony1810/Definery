//
//  RemoteWithLocalFallbackLoaderTests.swift
//  DefineryTests
//
//  Created by Anthony on 2/1/26.
//

import Foundation
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
    
    @Test func load_cacesRemoteWordsOnRemoteSuccess() async throws {
        let sut = makeSUT()
        let remoteWords = [uniqueWord()]
        
        sut.remote.complete(with: .success(remoteWords))
        
        _ = try await sut.loader.load()
        
        #expect(sut.cache.savedWords == remoteWords)
    }
    
    @Test func load_deliversCacheWordsOnRemoteFailure() async {
        let sut = makeSUT()
        let cachedWords = [uniqueWord()]
        
        sut.remote.complete(with: .failure(anyNSError()))
        sut.local.complete(with: .success(cachedWords))
        
        do {
            let result = try await sut.loader.load()
            #expect(result == cachedWords)
        } catch {
            Issue.record("Expected to succeed, but threw: \(error)")
        }
    }
    
    @Test func load_deliversErrorOnBothRemoteAndLocalFailure() async throws {
        let sut = makeSUT()
        let expectedError = anyNSError()
        
        sut.remote.complete(with: .failure(expectedError))
        sut.local.complete(with: .failure(expectedError))
        
        do {
            let result = try await sut.loader.load()
            Issue.record("expected to fail, but succeeded with: \(result)")
        } catch {
            #expect(error as NSError? == expectedError)
        }
    }
    
    @Test func load_doesNotCacheOnRemoteFailure() async {
        let sut = makeSUT()
        
        sut.remote.complete(with: .failure(anyNSError()))
        sut.local.complete(with: .success([]))
        
        _ = try? await sut.loader.load()
        
        #expect(sut.cache.savedWords.isEmpty)
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

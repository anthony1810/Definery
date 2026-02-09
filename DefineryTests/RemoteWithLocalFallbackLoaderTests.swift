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
    private var leakTrackers: [MemoryLeakTracker] = []

    deinit {
        leakTrackers.forEach { $0.verify() }
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
    private func trackForMemoryLeaks(
        _ instance: AnyObject,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        leakTrackers.append(MemoryLeakTracker(instance: instance, sourceLocation: sourceLocation))
    }

    private func makeSUT(
        sourceLocation: SourceLocation = #_sourceLocation
    ) -> (loader: RemoteWithLocalFallbackLoader, remote: WordLoaderSpy, local: WordLoaderSpy, cache: WordCacheSpy) {
        let remote = WordLoaderSpy()
        let local = WordLoaderSpy()
        let cache = WordCacheSpy()
        let loader = RemoteWithLocalFallbackLoader(remote: remote, local: local, cache: cache)

        trackForMemoryLeaks(loader, sourceLocation: sourceLocation)
        trackForMemoryLeaks(remote, sourceLocation: sourceLocation)
        trackForMemoryLeaks(local, sourceLocation: sourceLocation)
        trackForMemoryLeaks(cache, sourceLocation: sourceLocation)

        return (loader, remote, local, cache)
    }
}

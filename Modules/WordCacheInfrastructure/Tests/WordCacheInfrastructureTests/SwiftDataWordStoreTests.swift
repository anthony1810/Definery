//
//  SwiftDataWordStoreTests.swift
//  Definery
//
//  Created by Anthony on 2/1/26.
//

import Testing
import WordCacheInfrastructure

final class SwiftDataWordStoreTests {
    private var leakTrackers: [MemoryLeakTracker] = []

    deinit {
        leakTrackers.forEach { $0.verify() }
    }
    
    @Test func retrieve_deliversEmptyOnEmptyCache() async throws {
        let sut = try makeSUT()
        
        let words = try await sut.retrieveWords()
        
        #expect(words.isEmpty)
    }
    
    @Test func retrieve_hasNoSideEffectsOnEmptyCache() async throws {
        let sut = try makeSUT()
        
        let firstResult = try await sut.retrieveWords()
        let secondResult = try await sut.retrieveWords()
        
        #expect(firstResult.isEmpty)
        #expect(secondResult.isEmpty)
    }
    
    @Test func retrieve_deliversFoundValuesOnNonEmptyCache() async throws {
        let sut = try makeSUT()
        let expectedWords = [uniqueLocalWord()]
        
        try await sut.insertCache(words: expectedWords)
        let actualWords = try await sut.retrieveWords()
        
        #expect(actualWords == expectedWords)
    }
    
    @Test func retrieve_hasNoSideEffectsOnNonEmptyCache() async throws {
        let sut = try makeSUT()
        
        let firstResult = try await sut.retrieveWords()
        let secondResult = try await sut.retrieveWords()
        
        #expect(firstResult == secondResult)
    }
    
    @Test func insert_deliversNoErrorOnEmptyCache() async throws {
        let sut = try makeSUT()
        
        do {
            try await sut.insertCache(words: uniqueLocalWords())
        } catch {
            Issue.record("Expect no error, got \(error)")
        }
    }
    
    @Test func insert_deliversNoErrorOnNonEmptyCache() async throws {
        let sut = try makeSUT()

        do {
            try await sut.insertCache(words: uniqueLocalWords())
            try await sut.insertCache(words: uniqueLocalWords())
        } catch {
            Issue.record("Expect no error, got \(error)")
        }
    }
    
    @Test func insert_overridesPreviouslyInsertedCacheValues() async throws {
        let sut = try makeSUT()
        let expectedWords = [uniqueLocalWord()]
        
        try await sut.insertCache(words: uniqueLocalWords())
        try await sut.insertCache(words: expectedWords)
        
        let actualWords = try await sut.retrieveWords()
        
        #expect(actualWords == expectedWords)
    }
    
    @Test func delete_deliversNoErrorOnEmptyCache() async {
        do {
            let sut = try makeSUT()
            try await sut.deleteCachedWords()
        } catch {
            Issue.record("Expected no error, got \(error)")
        }
    }
    
    @Test func delete_hasNoSideEffectsOnEmptyCache() async throws {
        let sut = try makeSUT()
        
        let expectedWords = try await sut.retrieveWords()
        #expect(expectedWords.isEmpty)
        
        try await sut.deleteCachedWords()
        
        let actualWords = try await sut.retrieveWords()
        #expect(expectedWords == actualWords)
    }
    
    @Test func delete_emptiesPreviouslyInsertedCache() async throws {
        let sut = try makeSUT()
        
        try await sut.insertCache(words: uniqueLocalWords())
        try await sut.deleteCachedWords()
        
        let actualWords = try await sut.retrieveWords()
        #expect(actualWords.isEmpty)
    }
    
}
// MARK: - Helpers

extension SwiftDataWordStoreTests {
    private func trackForMemoryLeaks(
        _ instance: AnyObject,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        leakTrackers.append(MemoryLeakTracker(instance: instance, sourceLocation: sourceLocation))
    }

    private func makeSUT(
        sourceLocation: SourceLocation = #_sourceLocation
    ) throws -> SwiftDataWordStore {
        let sut = try SwiftDataWordStore(inMemory: true)
        trackForMemoryLeaks(sut, sourceLocation: sourceLocation)
        return sut
    }
}


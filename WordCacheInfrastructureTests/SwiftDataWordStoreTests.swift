//
//  SwiftDataWordStoreTests.swift
//  Definery
//
//  Created by Anthony on 2/1/26.
//

import Testing
import WordCacheInfrastructure

final class SwiftDataWordStoreTests {
    private var sutTracker: MemoryLeakTracker<SwiftDataWordStore>?
    
    deinit {
        sutTracker?.verify()
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
            let _ = try await sut.insertCache(words: uniqueLocalWords())
        } catch {
            Issue.record("Expect no error, got \(error)")
        }
    }
    
}
// MARK: - Helpers

extension SwiftDataWordStoreTests {
    private func makeSUT(
        fileId: String = #fileID,
        filePath: String = #filePath,
        line: Int = #line,
        column: Int = #column
    ) throws -> SwiftDataWordStore {
        let sut = try SwiftDataWordStore(inMemory: true)
        
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


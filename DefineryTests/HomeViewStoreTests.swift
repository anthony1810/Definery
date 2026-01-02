//
//  HomeViewStoreTests.swift
//  Definery
//
//  Created by Anthony on 2/1/26.
//

import Foundation
import Testing
import WordFeature

import ScreenStateKit
@testable import Definery

@MainActor
final class HomeViewStoreTests {
    private var sutTracker: MemoryLeakTracker<SUT>?
    
    deinit {
        sutTracker?.verify()
    }
    
    @Test func init_doesNotLoadWords() async {
        let sut = makeSUT()
        
        #expect(sut.loader.loadCallCount == 0)
    }
    
    @Test func loadWords_deliversEmptyWordsOnLoaderEmpty() async throws {
        let sut = makeSUT()
        
        sut.loader.complete(with: .success([]))
        try await sut.store.isolatedReceive(action: .loadWords)
        
        #expect(sut.state.words.isEmpty)
    }
    
    @Test func loadWords_deliversErrorOnLoaderError() async throws {
        let sut = makeSUT()
        let expectedError = anyNSError()
        
        do {
            sut.loader.complete(with: .failure(expectedError))
            try await sut.store.isolatedReceive(action: .loadWords)
        } catch {
            #expect(error as NSError? == expectedError)
        }
    }
}

// MARK: - Helpers

extension HomeViewStoreTests {
    final class SUT: Sendable {
        let store: HomeViewStore
        let loader: WordLoaderSpy
        let state: HomeViewState
        
        init(store: HomeViewStore, loader: WordLoaderSpy, state: HomeViewState) {
            self.store = store
            self.loader = loader
            self.state = state
        }
    }
    
    @MainActor
    private func makeSUT(
        fileId: String = #fileID,
        filePath: String = #filePath,
        line: Int = #line,
        column: Int = #column
    ) -> SUT {
        let loader = WordLoaderSpy()
        let state = HomeViewState()
        let store = HomeViewStore(loader: loader)
        
        let sut = SUT(store: store, loader: loader, state: state)
        
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

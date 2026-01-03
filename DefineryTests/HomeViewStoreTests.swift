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
import ConcurrencyExtras

@testable import Definery

@MainActor
final class HomeViewStoreTests {
    private var sutTracker: MemoryLeakTracker<SUT>?
    
    deinit {
        sutTracker?.verify()
    }
    
    // MARK: - Load
    
    @Test func init_doesNotLoadWords() async {
        let sut = await makeSUT()
        
        #expect(sut.loader.loadCallCount == 0)
    }
    
    @Test func loadWords_deliversEmptyWordsOnLoaderEmpty() async throws {
        let sut = await makeSUT()
        
        sut.loader.complete(with: .success([]))
        try await sut.store.isolatedReceive(action: .loadWords)
        
        #expect(sut.state.words.isEmpty)
    }
    
    @Test func loadWords_deliversErrorOnLoaderError() async throws {
        let sut = await makeSUT()
        let expectedError = anyNSError()
        
        do {
            sut.loader.complete(with: .failure(expectedError))
            try await sut.store.isolatedReceive(action: .loadWords)
            Issue.record("expected to throw, but it didn't")
        } catch {
            #expect(error as NSError? == expectedError)
        }
    }
    
    @Test func loadWords_deliversErrorToViewStateOnLoaderError() async throws {
        await withMainSerialExecutor {
            let sut = await makeSUT()
            let expectedError = anyNSError()

            sut.loader.complete(with: .failure(expectedError))
            sut.store.receive(action: .loadWords)

            await Task.megaYield()

            #expect(sut.state.displayError != nil)
        }
    }

    @Test func loadWords_transitionsToErrorStateOnLoaderError() async throws {
        await withMainSerialExecutor {
            let sut = await makeSUT()
            let expectedError = anyNSError()

            sut.loader.complete(with: .failure(expectedError))
            sut.store.receive(action: .loadWords)

            await Task.megaYield()

            #expect(sut.state.loadState == .error(expectedError.localizedDescription))
        }
    }

    @Test func loadWords_stopsLoadingOnError() async throws {
        await withMainSerialExecutor {
            let sut = await makeSUT()

            sut.loader.complete(with: .failure(anyNSError()))
            sut.store.receive(action: .loadWords)

            await Task.megaYield()

            #expect(sut.state.isLoading == false)
        }
    }
    
    @Test func loadWords_deliversWordsOnLoaderSuccess() async throws {
        let sut = await makeSUT()
        let expectedWords = [uniqueWord()]

        do {
            sut.loader.complete(with: .success(expectedWords))
            try await sut.store.isolatedReceive(action: .loadWords)

            #expect(sut.state.words == expectedWords)
        } catch {
            Issue.record("expected to succeed, but it failed with error: \(error)")
        }
    }

    @Test func loadWords_transitionsFromIdleToLoadedOnSuccess() async throws {
        let sut = await makeSUT()

        #expect(sut.state.loadState == .idle)

        sut.loader.complete(with: .success([]))
        try await sut.store.isolatedReceive(action: .loadWords)

        #expect(sut.state.loadState == .loaded([]))
    }
    
    @Test func loadWords_doesNotRequestLoadTwiceWhilePending() async throws {
        let sut = await makeSUT()
        
        sut.loader.complete(with: .success([]))
        
        async let first: () = sut.store.isolatedReceive(action: .loadWords)
        async let second: () = sut.store.isolatedReceive(action: .loadWords)
        
        _ = try await (first, second)
        
        #expect(sut.loader.loadCallCount == 1)
    }
    
    // MARK: - Load More
    
    @Test func loadMore_requestsLoadFromLoader() async throws {
        let sut = await makeSUT()
        
        sut.loader.complete(with: .success([]))
        try await sut.store.isolatedReceive(action: .loadMore)
        
        #expect(sut.loader.loadCallCount == 1)
    }
    
    @Test func loadMore_appendsWordsToExistingWords() async throws {
        await withMainSerialExecutor {
            let sut = await makeSUT()
            let initialWords = [uniqueWord(), uniqueWord()]
            let newWords = [uniqueWord()]
            
            sut.loader.complete(with: .success(initialWords))
            sut.store.receive(action: .loadWords)
            await Task.megaYield()
            
            sut.loader.complete(with: .success(newWords))
            sut.store.receive(action: .loadMore)
            await Task.megaYield()
            
            #expect(sut.state.words == initialWords + newWords)
        }
    }
    
    @Test func loadMore_doesNotDuplicaExistingWords() async throws {
        await withMainSerialExecutor {
            let sut = await makeSUT()
            let existingWord = uniqueWord()
            let newWord = uniqueWord()
            
            sut.loader.complete(with: .success([existingWord]))
            sut.store.receive(action: .loadWords)
            await Task.megaYield()
            
            sut.loader.complete(with: .success([existingWord, newWord]))
            sut.store.receive(action: .loadMore)
            await Task.megaYield()
            
            #expect(sut.state.words == [existingWord, newWord])
        }
    }
    
    @Test func loadMore_deliversErrorToViewStateOnLoaderError() async throws {
        await withMainSerialExecutor {
            let sut = await makeSUT()
            
            sut.loader.complete(with: .failure(anyNSError()))
            sut.store.receive(action: .loadMore)
            await Task.megaYield()
            
            #expect(sut.state.displayError != nil)
        }
    }
    
    @Test func loadMore_doesNotRequestLoadTwiceWhilePending() async throws {
        let sut = await makeSUT()
        
        sut.loader.complete(with: .success([]))
        async let firstLoad: () = sut.store.isolatedReceive(action: .loadMore)
        async let secondLoad: () = sut.store.isolatedReceive(action: .loadMore)
        
        _ = try await (firstLoad, secondLoad)
        
        #expect(sut.loader.loadCallCount == 1)
    }
    
    @Test func loadMore_keepExistingWordsOnError() async throws {
        await withMainSerialExecutor {
            let sut = await makeSUT()
            let initialWords = [uniqueWord(), uniqueWord()]
            
            sut.loader.complete(with: .success(initialWords))
            sut.store.receive(action: .loadWords)
            await Task.megaYield()
            
            sut.loader.complete(with: .failure(anyNSError()))
            sut.store.receive(action: .loadMore)
            await Task.megaYield()
            
            #expect(sut.state.words == initialWords)
        }
    }
    
    // MARK: - Select Language
    
    @Test func selectLanguage_updatesSelectedLanguage() async throws {
        await withMainSerialExecutor {
            let sut = await makeSUT()
            
            #expect(sut.state.selectedLanguage == .english)
            
            sut.loader.complete(with: .success([]))
            sut.store.receive(action: .selectLanguage(.spanish))
            await Task.megaYield()
            
            #expect(sut.state.selectedLanguage == .spanish)
        }
    }
    
    @Test func selectLanguage_clearsWordsAndReloadsFromLoader() async throws {
        await withMainSerialExecutor {
            let sut = await makeSUT()
            let englishWords = [uniqueWord()]
            let spanishWords = [uniqueWord()]
            
            // load english words
            sut.loader.complete(with: .success(englishWords))
            sut.store.receive(action: .loadWords)
            await Task.megaYield()
            
            #expect(sut.state.words == englishWords)
            
            // change language - should clear and reload
            sut.loader.complete(with: .success(spanishWords))
            sut.store.receive(action: .selectLanguage(.spanish))
            await Task.megaYield()
            
            #expect(sut.state.words == spanishWords)
            #expect(sut.loader.loadCallCount == 2)
        }
    }
    
    @Test func loadWords_requestsLoaderWithSelectedLanguage() async throws {
        await withMainSerialExecutor {
            let capturedSelectedLanguage = LockIsolated<[Locale.LanguageCode]>([])
            let loader = WordLoaderSpy()
            let store = HomeViewStore(loader: { language in
                capturedSelectedLanguage.withValue { $0.append(language) }
                return loader
            })
            let state = HomeViewState()
            await store.binding(state: state)

            loader.complete(with: .success([]))
            store.receive(action: .loadWords)
            await Task.megaYield()

            #expect(capturedSelectedLanguage.value == [.english])
        }
    }

    @Test func selectLanguage_transitionsToLoadedOnSuccess() async throws {
        await withMainSerialExecutor {
            let sut = await makeSUT()

            #expect(sut.state.loadState == .idle)

            sut.loader.complete(with: .success([]))
            sut.store.receive(action: .selectLanguage(.spanish))
            await Task.megaYield()

            #expect(sut.state.loadState == .loaded([]))
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
    ) async -> SUT {
        let loader = WordLoaderSpy()
        let state = HomeViewState()
        let store = HomeViewStore(loader: { _ in loader })
        
        await store.binding(state: state)
        
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

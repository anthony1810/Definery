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
    private nonisolated(unsafe) var leakTrackers: [MemoryLeakTracker] = []

    deinit {
        leakTrackers.forEach { $0.verify() }
    }

    // MARK: - Load

    @Test func init_doesNotLoadWords() async {
        let sut = await makeSUT()

        #expect(sut.loader.loadCallCount == 0)
    }

    @Test func loadWords_deliversEmptyWordsOnLoaderEmpty() async {
        let sut = await makeSUT()

        sut.loader.complete(with: .success([]))
        await sut.store.isolatedReceive(action: .loadWords)

        #expect(sut.state.snapshot.words.isEmpty)
    }

    @Test func loadWords_deliversErrorToViewStateOnLoaderError() async {
        await withMainSerialExecutor {
            let sut = await makeSUT()
            let expectedError = anyNSError()

            sut.loader.complete(with: .failure(expectedError))
            sut.store.receive(action: .loadWords)

            await Task.megaYield()

            #expect(sut.state.displayError != nil)
        }
    }

    @Test func loadWords_stopsLoadingOnError() async {
        await withMainSerialExecutor {
            let sut = await makeSUT()

            sut.loader.complete(with: .failure(anyNSError()))
            sut.store.receive(action: .loadWords)

            await Task.megaYield()

            #expect(sut.state.isLoading == false)
        }
    }

    @Test func loadWords_deliversWordsOnLoaderSuccess() async {
        let sut = await makeSUT()
        let expectedWords = [uniqueWord()]

        sut.loader.complete(with: .success(expectedWords))
        await sut.store.isolatedReceive(action: .loadWords)

        #expect(sut.state.snapshot.words == expectedWords)
    }

    @Test func loadWords_clearsErrorOnSuccess() async {
        await withMainSerialExecutor {
            let sut = await makeSUT()

            // First trigger an error
            sut.loader.complete(with: .failure(anyNSError()))
            sut.store.receive(action: .loadWords)
            await Task.megaYield()

            #expect(sut.state.displayError != nil)

            // Then load successfully
            sut.loader.complete(with: .success([]))
            sut.store.receive(action: .loadWords)
            await Task.megaYield()

            #expect(sut.state.displayError == nil)
        }
    }

    @Test func loadWords_doesNotRequestLoadTwiceWhilePending() async {
        await withMainSerialExecutor {
            let sut = await makeSUT()

            sut.loader.complete(with: .success([]))

            async let first: () = sut.store.isolatedReceive(action: .loadWords)
            async let second: () = sut.store.isolatedReceive(action: .loadWords)

            _ = await (first, second)

            #expect(sut.loader.loadCallCount == 1)
        }
    }

    // MARK: - Load More

    @Test func loadMore_requestsLoadFromLoader() async {
        let sut = await makeSUT()

        sut.loader.complete(with: .success([]))
        await sut.store.isolatedReceive(action: .loadMore)

        #expect(sut.loader.loadCallCount == 1)
    }

    @Test func loadMore_appendsWordsToExistingWords() async {
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

            #expect(sut.state.snapshot.words == initialWords + newWords)
        }
    }

    @Test func loadMore_doesNotDuplicateExistingWords() async {
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

            #expect(sut.state.snapshot.words == [existingWord, newWord])
        }
    }

    @Test func loadMore_deliversErrorToViewStateOnLoaderError() async {
        await withMainSerialExecutor {
            let sut = await makeSUT()

            sut.loader.complete(with: .failure(anyNSError()))
            sut.store.receive(action: .loadMore)
            await Task.megaYield()

            #expect(sut.state.displayError != nil)
        }
    }

    @Test func loadMore_terminatesLoadmoreViewOnError() async {
        await withMainSerialExecutor {
            let sut = await makeSUT()

            // Simulate loadmore view is showing
            sut.state.canExecuteLoadmore()
            #expect(sut.state.canShowLoadmore == true)

            sut.loader.complete(with: .failure(anyNSError()))
            sut.store.receive(action: .loadMore)
            await Task.megaYield()

            #expect(sut.state.canShowLoadmore == false)
        }
    }

    @Test func loadMore_doesNotRequestLoadTwiceWhilePending() async {
        await withMainSerialExecutor {
            let sut = await makeSUT()

            sut.loader.complete(with: .success([]))
            async let firstLoad: () = sut.store.isolatedReceive(action: .loadMore)
            async let secondLoad: () = sut.store.isolatedReceive(action: .loadMore)

            _ = await (firstLoad, secondLoad)

            #expect(sut.loader.loadCallCount == 1)
        }
    }

    @Test func loadMore_keepExistingWordsOnError() async {
        await withMainSerialExecutor {
            let sut = await makeSUT()
            let initialWords = [uniqueWord(), uniqueWord()]

            sut.loader.complete(with: .success(initialWords))
            sut.store.receive(action: .loadWords)
            await Task.megaYield()

            sut.loader.complete(with: .failure(anyNSError()))
            sut.store.receive(action: .loadMore)
            await Task.megaYield()

            #expect(sut.state.snapshot.words == initialWords)
        }
    }

    // MARK: - Select Language

    @Test func selectLanguage_updatesSelectedLanguage() async {
        await withMainSerialExecutor {
            let sut = await makeSUT()

            #expect(sut.state.snapshot.selectedLanguage == .english)

            sut.loader.complete(with: .success([]))
            sut.store.receive(action: .selectLanguage(.spanish))
            await Task.megaYield()

            #expect(sut.state.snapshot.selectedLanguage == .spanish)
        }
    }

    @Test func selectLanguage_clearsWordsAndReloadsFromLoader() async {
        await withMainSerialExecutor {
            let sut = await makeSUT()
            let englishWords = [uniqueWord()]
            let spanishWords = [uniqueWord()]

            // load english words
            sut.loader.complete(with: .success(englishWords))
            sut.store.receive(action: .loadWords)
            await Task.megaYield()

            #expect(sut.state.snapshot.words == englishWords)

            // change language - should clear and reload
            sut.loader.complete(with: .success(spanishWords))
            sut.store.receive(action: .selectLanguage(.spanish))
            await Task.megaYield()

            #expect(sut.state.snapshot.words == spanishWords)
            #expect(sut.loader.loadCallCount == 2)
        }
    }

    @Test func loadWords_requestsLoaderWithSelectedLanguage() async {
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

    @Test func selectLanguage_setsWordsOnSuccess() async {
        await withMainSerialExecutor {
            let sut = await makeSUT()
            let expectedWords = [uniqueWord()]

            sut.loader.complete(with: .success(expectedWords))
            sut.store.receive(action: .selectLanguage(.spanish))
            await Task.megaYield()

            #expect(sut.state.snapshot.words == expectedWords)
        }
    }
}

// MARK: - Helpers

extension HomeViewStoreTests {
    private func trackForMemoryLeaks(
        _ instance: AnyObject,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        leakTrackers.append(MemoryLeakTracker(instance: instance, sourceLocation: sourceLocation))
    }

    @MainActor
    private func makeSUT(
        sourceLocation: SourceLocation = #_sourceLocation
    ) async -> (store: HomeViewStore, loader: WordLoaderSpy, state: HomeViewState) {
        let loader = WordLoaderSpy()
        let state = HomeViewState()
        let store = HomeViewStore(loader: { _ in loader })

        await store.binding(state: state)

        trackForMemoryLeaks(store, sourceLocation: sourceLocation)
        trackForMemoryLeaks(loader, sourceLocation: sourceLocation)
        trackForMemoryLeaks(state, sourceLocation: sourceLocation)

        return (store, loader, state)
    }
}

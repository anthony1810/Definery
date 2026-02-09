//
//  HomeViewStore.swift
//  Definery
//
//  Created by Anthony on 2/1/26.
//
import Foundation
import ScreenStateKit
import WordFeature

typealias WordLoaderFactory = @Sendable (Locale.LanguageCode) -> WordLoaderProtocol

actor HomeViewStore: ScreenActionStore {
    private var state: HomeViewState?
    private let actionLocker = ActionLocker.isolated

    enum Action: ActionLockable, LoadingTrackable, Hashable {
        case loadWords
        case refresh
        case loadMore
        case selectLanguage(Locale.LanguageCode)

        var canTrackLoading: Bool {
            switch self {
            case .loadWords, .selectLanguage:
                return true
            case .refresh, .loadMore:
                return false
            }
        }
    }

    private let loaderFactory: WordLoaderFactory

    init(loader: @escaping WordLoaderFactory) {
        self.loaderFactory = loader
    }

    func binding(state: HomeViewState) {
        self.state = state
    }

    nonisolated func receive(action: Action) {
        Task { await isolatedReceive(action: action) }
    }

    func isolatedReceive(action: Action) async {
        guard await actionLocker.canExecute(action) else { return }
        await state?.loadingStarted(action: action)

        do {
            switch action {
            case .loadWords, .refresh:
                try await loadWords()
            case .loadMore:
                try await loadMore()
            case .selectLanguage(let language):
                try await selectLanguage(language)
            }
            // Clear error on success for main actions
            if case .loadWords = action {
                await state?.updateState { $0.displayError = nil }
            }
        } catch {
            await handleError(error, for: action)
        }

        await actionLocker.unlock(action)
        await state?.loadingFinished(action: action)
    }
}

// MARK: - Actions

extension HomeViewStore {
    private func loadWords() async throws {
        let selectedLanguage = await state?.snapshot.selectedLanguage ?? .english
        let loader = loaderFactory(selectedLanguage)
        let words = try await loader.load()

        await state?.updateState { state in
            state.snapshot = HomeSnapshot(words: words, selectedLanguage: selectedLanguage)
        }

        /// sometimes free apis return less than needed words
        /// for progress view to show again
        await state?.canExecuteLoadmore()
    }

    private func loadMore() async throws {
        guard let state = state else { return }
        
        let currentSnapshot = await state.snapshot
        let loader = loaderFactory(currentSnapshot.selectedLanguage)
        let newWords = try await loader.load()

        let uniqueNewWords = newWords.filter { !currentSnapshot.words.contains($0) }
        let allWords = currentSnapshot.words + uniqueNewWords

        await state.updateState { state in
            state.snapshot = HomeSnapshot(
                words: allWords,
                selectedLanguage: currentSnapshot.selectedLanguage
            )
        }

        // We will never load all words in this app
        await state.updateDidLoadAllData(false)
    }

    private func selectLanguage(_ language: Locale.LanguageCode) async throws {
        // Show placeholder with new language selected immediately
        await state?.updateState { state in
            state.snapshot = .placeholder(for: language)
        }

        let loader = loaderFactory(language)
        let words = try await loader.load()

        await state?.updateState { state in
            state.snapshot = HomeSnapshot(words: words, selectedLanguage: language)
        }
    }
}

// MARK: - Error Handling

extension HomeViewStore {
    private func handleError(_ error: Error, for action: Action) async {
        let currentLanguage = await state?.snapshot.selectedLanguage ?? .english

        switch action {
        case .loadWords, .refresh, .selectLanguage:
            await state?.updateState { state in
                state.snapshot = HomeSnapshot(words: [], selectedLanguage: currentLanguage)
            }
        case .loadMore:
            await state?.ternimateLoadmoreView()
        }
        await state?.showError(AppError.abnormalState(error.localizedDescription))
    }
}

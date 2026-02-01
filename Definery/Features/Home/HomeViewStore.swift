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
    private let actionLocker = ActionLocker()

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
        let selectedLanguage = await state?.selectedLanguage ?? .english
        let loader = loaderFactory(selectedLanguage)
        let words = try await loader.load()

        await state?.updateState { state in
            state.words = words
            state.errorMessage = nil
        }

        /// sometimes free apis return less than needed words
        /// for progress view to show again
        await state?.canExecuteLoadmore()
    }

    private func loadMore() async throws {
        let selectedLanguage = await state?.selectedLanguage ?? .english
        let currentWords = await state?.words ?? []

        let loader = loaderFactory(selectedLanguage)
        let newWords = try await loader.load()

        let uniqueNewWords = newWords.filter { !currentWords.contains($0) }

        await state?.updateState { state in
            state.words = currentWords + uniqueNewWords
        }

        // We will never load all words in this app
        await state?.updateDidLoadAllData(false)
    }

    private func selectLanguage(_ language: Locale.LanguageCode) async throws {
        await state?.updateState { state in
            state.selectedLanguage = language
            state.words = []
            state.errorMessage = nil
        }

        let loader = loaderFactory(language)
        let words = try await loader.load()

        await state?.updateState { state in
            state.words = words
        }
    }
}

// MARK: - Error Handling

extension HomeViewStore {
    private func handleError(_ error: Error, for action: Action) async {
        switch action {
        case .loadWords, .refresh, .selectLanguage:
            await state?.updateState { state in
                state.errorMessage = error.localizedDescription
            }
        case .loadMore:
            await state?.ternimateLoadmoreView()
        }
        await state?.showError(AppError.abnormalState(error.localizedDescription))
    }
}

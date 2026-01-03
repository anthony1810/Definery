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
    public typealias ScreenState = HomeViewState
  
    weak var viewState: HomeViewState?
    
    private let actionLocker = ActionLocker()
    
    enum Action: ActionLockable, LoadingTrackable, Sendable {
        case loadWords
        case loadMore
        case selectLanguage(Locale.LanguageCode)
        
        var canTrackLoading: Bool {
            true
        }
    }
    
    private let loaderFactory: WordLoaderFactory
    
    init(loader: @escaping WordLoaderFactory) {
        self.loaderFactory = loader
    }
    
    func binding(state: HomeViewState) {
        self.viewState = state
    }
    
    nonisolated func receive(action: Action) {
        Task {
            do {
                try await isolatedReceive(action: action)
            } catch {
                await handleError(error, for: action)
            }
        }
    }
    
    func isolatedReceive(action: Action) async throws {
        guard await actionLocker.canExecute(action) else { return }
        await viewState?.loadingStarted()
        
        do {
            switch action {
            case .loadWords:
                try await loadWords()
            case .loadMore:
                try await loadMore()
            case .selectLanguage(let language):
                try await selectLanguage(language)
            }
            
            await actionLocker.unlock(action)
            await viewState?.loadingFinished()
        } catch {
            await actionLocker.unlock(action)
            await viewState?.loadingFinished()
            throw error
        }
    }
}

// MARK: - Actions

extension HomeViewStore {
    private func loadWords() async throws {
        let selectedLanguage = await viewState?.selectedLanguage ?? .english
        let loader = loaderFactory(selectedLanguage)
        let words = try await loader.load()
        await viewState?.tryUpdate(property: \.loadState, newValue: .loaded(words))
    }
    
    private func loadMore() async throws {
        let selectedLanguage = await viewState?.selectedLanguage ?? .english
        let loader = loaderFactory(selectedLanguage)
        let newWords = try await loader.load()
        let currentWords = await viewState?.words ?? []
        let uniqueNewWords = newWords.filter { !currentWords.contains($0) }
        await viewState?.tryUpdate(property: \.loadState, newValue: .loaded(currentWords + uniqueNewWords))
    }
    
    private func selectLanguage(_ language: Locale.LanguageCode) async throws {
        await viewState?.tryUpdate(property: \.selectedLanguage, newValue: language)
        await viewState?.tryUpdate(property: \.loadState, newValue: .idle)
        
        let loader = loaderFactory(language)
        let words = try await loader.load()
        await viewState?.tryUpdate(property: \.loadState, newValue: .loaded(words))
    }
}

// MARK: - Helpers

extension HomeViewStore {
    private func handleError(_ error: Error, for action: Action) async {
        switch action {
        case .loadWords, .selectLanguage:
            await viewState?.tryUpdate(property: \.loadState, newValue: .error(error.localizedDescription))
        case .loadMore:
            // Keep existing words on loadMore error, only show alert
            break
        }
        await viewState?.showError(AppError.abnormalState(error.localizedDescription))
    }
}

//
//  HomeViewStore.swift
//  Definery
//
//  Created by Anthony on 2/1/26.
//

import SwiftUI
import Observation

import ScreenStateKit
import WordFeature

@MainActor @Observable
final class HomeViewState: ScreenState {
    private(set) var words: [Word] = []
    private(set) var selectedLanguage: Locale.LanguageCode = .english
    
    func tryUpdate<T>(property: @autoclosure @MainActor () -> KeyPath<HomeViewState, T>,
                      newValue: T) {
      guard let keypath = property() as? ReferenceWritableKeyPath<HomeViewState, T> else {
        assertionFailure("Read-only property")
        return
      }
      self[keyPath: keypath] = newValue
    }
}

actor HomeViewStore: ScreenActionStore {
    public typealias ScreenState = HomeViewState
    public typealias LoaderFactory = @Sendable (Locale.LanguageCode) -> WordLoaderProtocol
    
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
    
    private let loaderFactory: LoaderFactory
    
    init(loader: @escaping LoaderFactory) {
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
                await viewState?.showError(AppError.abnormalState(error.localizedDescription))
            }
        }
    }
    
    func isolatedReceive(action: Action) async throws {
        guard await actionLocker.canExecute(action) else { return }
        await viewState?.loadingStarted()
        
        let selectedLanguage = await viewState?.selectedLanguage ?? .english
        let loader = loaderFactory(selectedLanguage)

        switch action {
        case .loadWords:
            let words = try await loader.load()
            await viewState?.tryUpdate(property: \.words, newValue: words)
        case .loadMore:
            let newWords = try await loader.load()
            let currentWords = await viewState?.words ?? []
            let uniqueNewWords = newWords.filter { !currentWords.contains($0) }
            await viewState?.tryUpdate(property: \.words, newValue: currentWords + uniqueNewWords)
        case .selectLanguage(let language):
            await viewState?.tryUpdate(property: \.selectedLanguage, newValue: language)
            await viewState?.tryUpdate(property: \.words, newValue: [])

            let newLoader = loaderFactory(language)
            let wordsFromNewSelectedLanguage = try await newLoader.load()
            await viewState?.tryUpdate(property: \.words, newValue: wordsFromNewSelectedLanguage)
        }
        
        await actionLocker.unlock(action)
        await viewState?.loadingFinished()
    }
}

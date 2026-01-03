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
    weak var viewState: HomeViewState?
    
    private let actionLocker = ActionLocker()
    
    enum Action: ActionLockable, LoadingTrackable, Sendable {
        case loadWords
        case loadMore
        
        var canTrackLoading: Bool {
            true
        }
    }
    
    private let loader: WordLoaderProtocol
    init(loader: WordLoaderProtocol) {
        self.loader = loader
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
        
        switch action {
        case .loadWords:
            let words = try await loader.load()
            await viewState?.tryUpdate(property: \.words, newValue: words)
        case .loadMore:
            let _ = try await loader.load()
        }
        
        await actionLocker.unlock(action)
        await viewState?.loadingFinished()
    }
}

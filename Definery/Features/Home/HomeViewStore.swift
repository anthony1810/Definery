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
}

actor HomeViewStore: ScreenActionStore {
    public typealias ScreenState = HomeViewState
    weak var viewState: HomeViewState?
    
    private let actionLocker = ActionLocker()
    
    enum Action: ActionLockable, LoadingTrackable, Sendable {
        case loadWords
        
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
        switch action {
        case .loadWords:
            let _ = try await loader.load()
            
        }
    }
}

//
//  HomeViewState.swift
//  Definery
//
//  Created by Anthony on 3/1/26.
//
import SwiftUI
import Observation

import WordFeature
import ScreenStateKit

@MainActor @Observable
final class HomeViewState: ScreenState {
    enum LoadState: Equatable {
        case idle
        case loaded([Word])
        case error(String)
        
        static func == (lhs: LoadState, rhs: LoadState) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle):
                return true
            case let (.loaded(lhsWords), .loaded(rhsWords)):
                return lhsWords == rhsWords
            case let (.error(lhsMessage), .error(rhsMessage)):
                return lhsMessage == rhsMessage
            default:
                return false
            }
        }
    }
    
    private(set) var loadState: LoadState = .idle
    private(set) var selectedLanguage: Locale.LanguageCode = .english
    private(set) var isLoadingMore: Bool = false
    
    var words: [Word] {
        if case .loaded(let words) = loadState {
            return words
        }
        return []
    }
    
    func tryUpdate<T>(property: @autoclosure @MainActor () -> KeyPath<HomeViewState, T>,
                      newValue: T) {
        guard let keypath = property() as? ReferenceWritableKeyPath<HomeViewState, T> else {
            assertionFailure("Read-only property")
            return
        }
        self[keyPath: keypath] = newValue
    }
}

//
//  HomeSnapshot.swift
//  Definery
//
//  Created by Anthony on 2/2/26.
//

import Foundation
import ScreenStateKit
import WordFeature

/// Snapshot of home screen data for skeleton loading support.
struct HomeSnapshot: Equatable, Sendable {
    let words: [Word]
    let selectedLanguage: Locale.LanguageCode
    private let _isPlaceholder: Bool

    var isEmpty: Bool { words.isEmpty }
    var hasWords: Bool { !words.isEmpty }

    init(words: [Word], selectedLanguage: Locale.LanguageCode) {
        self.words = words
        self.selectedLanguage = selectedLanguage
        self._isPlaceholder = false
    }

    private init(words: [Word], selectedLanguage: Locale.LanguageCode, isPlaceholder: Bool) {
        self.words = words
        self.selectedLanguage = selectedLanguage
        self._isPlaceholder = isPlaceholder
    }

    static let empty = HomeSnapshot(words: [], selectedLanguage: .english)
}

// MARK: - PlaceholderRepresentable

extension HomeSnapshot: PlaceholderRepresentable {
    static var placeholder: HomeSnapshot {
        HomeSnapshot(words: Word.mocks, selectedLanguage: .english, isPlaceholder: true)
    }

    var isPlaceholder: Bool {
        _isPlaceholder
    }
}

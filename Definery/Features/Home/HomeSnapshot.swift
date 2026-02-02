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

    var isEmpty: Bool { words.isEmpty }
    var hasWords: Bool { !words.isEmpty }

    static let empty = HomeSnapshot(words: [], selectedLanguage: .english)
}

// MARK: - PlaceholderRepresentable

extension HomeSnapshot: PlaceholderRepresentable {
    static var placeholder: HomeSnapshot {
        HomeSnapshot(words: Word.mocks, selectedLanguage: .english)
    }

    var isPlaceholder: Bool {
        self == .placeholder
    }
}

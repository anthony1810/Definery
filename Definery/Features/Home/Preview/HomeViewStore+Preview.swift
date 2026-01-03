//
//  HomeViewStore+Preview.swift
//  Definery
//
//  Created by Anthony on 3/1/26.
//

import Foundation
import WordFeature

#if DEBUG
extension HomeViewState {
    static func preview(
        words: [Word] = Word.samples,
        selectedLanguage: Locale.LanguageCode = .english
    ) -> HomeViewState {
        let state = HomeViewState()
        state.tryUpdate(property: \.words, newValue: words)
        state.tryUpdate(property: \.selectedLanguage, newValue: selectedLanguage)
        return state
    }

    static var previewLoading: HomeViewState {
        let state = HomeViewState()
        state.loadingStarted()
        return state
    }
}

extension HomeViewStore {
    static var preview: HomeViewStore {
        HomeViewStore(loader: { _ in
            PreviewWordLoader()
        })
    }
}

private struct PreviewWordLoader: WordLoaderProtocol {
    func load() async throws -> [Word] {
        try? await Task.sleep(for: .seconds(1))
        return Word.samples
    }
}
#endif

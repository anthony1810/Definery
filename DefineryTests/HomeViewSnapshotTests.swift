//
//  HomeViewSnapshotTests.swift
//  Definery
//
//  Created by Anthony on 3/1/26.
//

import Foundation
import SwiftUI
import Testing

import SnapshotTesting
import ConcurrencyExtras
import WordFeature

@testable import Definery

@MainActor
@Suite("HomeViewSnapshotTests")
struct HomeViewSnapshotTests {
    @Test("HomeView with words shows word list")
    func homeView_withWords_showsWordList() async throws {
        let view = makeSUT(result: .success(Word.mocks))
                
        assertSnapshot(
            of: view,
            as: .image(
                precision: 0.96,
                perceptualPrecision: 0.97,
                layout: .device(config: .iPhone13)
            ),
            record: false
        )
    }
}

// MARK: - Helpers

extension HomeViewSnapshotTests {
    private func makeSUT(
        result: Result<[Word], Error>,
        selectedLanguage: Locale.LanguageCode = .english
    ) -> some View {
        let viewState = makeState(result: result, selectedLanguage: selectedLanguage)
        let loader = makeLoader(result: result)
        let viewStore = HomeViewStore(loader: { _ in loader })

        let view = HomeView(viewStore: viewStore, viewState: viewState)

        return view
    }

    private func makeState(
        result: Result<[Word], Error>,
        selectedLanguage: Locale.LanguageCode
    ) -> HomeViewState {
        let viewState = HomeViewState()

        switch result {
        case .success(let words):
            viewState.tryUpdate(property: \.loadState, newValue: .loaded(words))
        case .failure(let error):
            viewState.tryUpdate(property: \.loadState, newValue: .error(error.localizedDescription))
        }
        viewState.tryUpdate(property: \.selectedLanguage, newValue: selectedLanguage)

        return viewState
    }

    private func makeLoader(result: Result<[Word], Error>) -> WordLoaderSpy {
        let loader = WordLoaderSpy()
        loader.complete(with: result)
        return loader
    }
}

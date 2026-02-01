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
import WordFeature

@testable import Definery

@MainActor
final class HomeViewSnapshotTests {
    @Test("HomeView with words shows word list")
    func homeView_withWords_showsWordList() async throws {
        let view = makeSUT(words: Word.mocks)

        assertHomeViewSnapshot(of: view, named: "light", colorScheme: .light)
        assertHomeViewSnapshot(of: view, named: "dark", colorScheme: .dark)
    }

    @Test("HomeView with empty words shows empty state")
    func homeView_withEmptyWords_showsEmptyState() async throws {
        let view = makeSUT(words: [])

        assertHomeViewSnapshot(of: view, named: "light", colorScheme: .light)
        assertHomeViewSnapshot(of: view, named: "dark", colorScheme: .dark)
    }

    @Test("HomeView with error shows error state")
    func homeView_withError_showsErrorState() async throws {
        let view = makeSUT(errorMessage: "Something went wrong")

        assertHomeViewSnapshot(of: view, named: "light", colorScheme: .light)
        assertHomeViewSnapshot(of: view, named: "dark", colorScheme: .dark)
    }
}

// MARK: - Helpers

extension HomeViewSnapshotTests {
    private func makeSUT(
        words: [Word] = [],
        errorMessage: String? = nil,
        selectedLanguage: Locale.LanguageCode = .english
    ) -> some View {
        let viewState = makeState(
            words: words,
            errorMessage: errorMessage,
            selectedLanguage: selectedLanguage
        )
        let loader = WordLoaderSpy()
        loader.complete(with: .success(words))
        let viewStore = HomeViewStore(loader: { _ in loader })

        return HomeView(viewStore: viewStore, viewState: viewState)
    }

    private func makeState(
        words: [Word],
        errorMessage: String?,
        selectedLanguage: Locale.LanguageCode
    ) -> HomeViewState {
        let viewState = HomeViewState()
        viewState.words = words
        viewState.errorMessage = errorMessage
        viewState.selectedLanguage = selectedLanguage
        return viewState
    }

    private func assertHomeViewSnapshot<V: View>(
        of view: V,
        named name: String,
        colorScheme: ColorScheme,
        file: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line
    ) {
        let snapshotDirectory = resolveSnapshotDirectory(
            testClassName: "HomeViewSnapshotTests",
            testName: testName,
            file: file
        )

        let themedView = view
            .environment(\.colorScheme, colorScheme)

        let failure = verifySnapshot(
            of: themedView,
            as: .image(
                precision: 0.93,
                perceptualPrecision: 0.93,
                layout: .device(config: .iPhone13)
            ),
            named: name,
            snapshotDirectory: snapshotDirectory,
            file: file,
            testName: testName,
            line: line
        )

        #expect(failure == nil, "\(failure ?? "")")
    }
}

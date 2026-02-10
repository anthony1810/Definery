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
import ScreenStateKit

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

    @Test("HomeView with placeholder shows skeleton loading")
    func homeView_withPlaceholder_showsSkeletonLoading() async throws {
        let view = makeSUT(isPlaceholder: true)

        assertHomeViewSnapshot(of: view, named: "light", colorScheme: .light)
        assertHomeViewSnapshot(of: view, named: "dark", colorScheme: .dark)
    }

    @Test("HomeView with few words shows load more progress")
    func homeView_withFewWords_showsLoadMoreProgress() async throws {
        let view = makeSUT(words: [Word.mocks[0]], canShowLoadmore: true)

        assertHomeViewSnapshot(of: view, named: "light", colorScheme: .light)
        assertHomeViewSnapshot(of: view, named: "dark", colorScheme: .dark)
    }
}

// MARK: - Helpers

extension HomeViewSnapshotTests {
    private func makeSUT(
        words: [Word] = [],
        errorMessage: String? = nil,
        selectedLanguage: Locale.LanguageCode = .english,
        isPlaceholder: Bool = false,
        canShowLoadmore: Bool = false
    ) -> some View {
        let viewState = makeState(
            words: words,
            errorMessage: errorMessage,
            selectedLanguage: selectedLanguage,
            isPlaceholder: isPlaceholder,
            canShowLoadmore: canShowLoadmore
        )
        let loader = WordLoaderSpy()
        loader.complete(with: .success(words))
        let viewStore = HomeViewStore(loader: { _ in loader })

        let homeView = HomeView(viewStore: viewStore, viewState: viewState)

        return VStack(alignment: .leading, spacing: 0) {
            Text("Definery")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.horizontal)
                .padding(.top, 16)

            homeView.contentBody
        }
    }

    private func makeState(
        words: [Word],
        errorMessage: String?,
        selectedLanguage: Locale.LanguageCode,
        isPlaceholder: Bool = false,
        canShowLoadmore: Bool = false
    ) -> HomeViewState {
        let viewState = HomeViewState()
        if isPlaceholder {
            viewState.snapshot = .placeholder
        } else {
            viewState.snapshot = HomeSnapshot(words: words, selectedLanguage: selectedLanguage)
        }
        if let errorMessage = errorMessage {
            viewState.displayError = DisplayableError(message: errorMessage)
        }
        if canShowLoadmore {
            viewState.canExecuteLoadmore()
        }
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
            .background(colorScheme == .dark ? Color.black : Color.white)

        let failure = verifySnapshot(
            of: themedView,
            as: .image(
                precision: 0.95,
                layout: .device(config: .iPhone16Pro)
            ),
            named: name,
            record: false,
            snapshotDirectory: snapshotDirectory,
            file: file,
            testName: testName,
            line: line
        )

        #expect(failure == nil, "\(failure ?? "")")
    }
}


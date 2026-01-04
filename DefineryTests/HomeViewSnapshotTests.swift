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

// Snapshot directory path computed at compile time from #filePath
private let snapshotBasePath: String = {
    let filePath = #filePath
    let url = URL(fileURLWithPath: filePath)
    return url
        .deletingLastPathComponent()
        .appendingPathComponent("Snapshots")
        .appendingPathComponent("HomeViewSnapshotTests")
        .path
}()

@MainActor
final class HomeViewSnapshotTests {
    @Test("HomeView with words shows word list")
    func homeView_withWords_showsWordList() async throws {
        let view = makeSUT(result: .success(Word.mocks))

        assertHomeViewSnapshot(of: view)
    }

    @Test("HomeView with empty words shows empty state")
    func homeView_withEmptyWords_showsEmptyState() async throws {
        let view = makeSUT(result: .success([]))

        assertHomeViewSnapshot(of: view)
    }

    @Test("HomeView with error shows error state")
    func homeView_withError_showsErrorState() async throws {
        let view = makeSUT(result: .failure(anyNSError()))

        assertHomeViewSnapshot(of: view)
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

        return HomeView(viewStore: viewStore, viewState: viewState)
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

    private func anyNSError() -> NSError {
        NSError(domain: "test", code: 0, userInfo: [NSLocalizedDescriptionKey: "Something went wrong"])
    }

    private func assertHomeViewSnapshot<V: View>(
        of view: V,
        file: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line
    ) {
        let failure = verifySnapshot(
            of: view,
            as: .image(
                precision: 0.96,
                perceptualPrecision: 0.97,
                layout: .device(config: .iPhone13)
            ),
            snapshotDirectory: snapshotBasePath,
            file: file,
            testName: testName,
            line: line
        )

        #expect(failure == nil, "\(failure ?? "")")
    }
}

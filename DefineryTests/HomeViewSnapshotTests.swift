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

// MARK: - Snapshot Directory Resolution

/// Resolves snapshot directory for both local development and CI (Xcode Cloud).
/// - Local: Uses #filePath to find Snapshots folder next to test file
/// - CI: Checks ci_scripts folder (accessible in Xcode Cloud) or test bundle resources
private func resolveSnapshotDirectory(
    testClassName: String,
    testName: String,
    file: StaticString
) -> String? {
    let sanitizedTestName = sanitizePathComponent(testName)
    let snapshotFileName = "\(sanitizedTestName).1.png"

    // 1. Check ci_scripts folder (Xcode Cloud copies this folder to test environment)
    let ciScriptsCandidates = [
        // ci_scripts at project root (test-without-building)
        "/Volumes/workspace/repository/ci_scripts/Snapshots/\(testClassName)",
        // Alternative path structure
        URL(fileURLWithPath: "\(file)")
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("ci_scripts")
            .appendingPathComponent("Snapshots")
            .appendingPathComponent(testClassName)
            .path
    ]

    for candidate in ciScriptsCandidates {
        let snapshotPath = (candidate as NSString).appendingPathComponent(snapshotFileName)
        if FileManager.default.fileExists(atPath: snapshotPath) {
            return candidate
        }
    }

    // 2. Check test bundle resources (if snapshots are bundled)
    let testBundle = Bundle(for: BundleToken.self)
    if let resourceURL = testBundle.resourceURL {
        let bundleCandidates = [
            resourceURL.appendingPathComponent("Snapshots").appendingPathComponent(testClassName),
            resourceURL.appendingPathComponent(testClassName)
        ]

        for candidate in bundleCandidates {
            let snapshotFile = candidate.appendingPathComponent(snapshotFileName)
            if FileManager.default.fileExists(atPath: snapshotFile.path) {
                return candidate.path
            }
        }
    }

    // 3. Fall back to file-based path for local development
    let url = URL(fileURLWithPath: "\(file)", isDirectory: false)
    return url
        .deletingLastPathComponent()
        .appendingPathComponent("Snapshots")
        .appendingPathComponent(testClassName)
        .path
}

/// Sanitizes test function name to match snapshot file naming convention
/// Copied from swift-snapshot-testing
private func sanitizePathComponent(_ string: String) -> String {
    string
        .replacingOccurrences(of: "\\W+", with: "-", options: .regularExpression)
        .replacingOccurrences(of: "^-|-$", with: "", options: .regularExpression)
}

/// Token class to get the test bundle
private final class BundleToken {}

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
        let snapshotDirectory = resolveSnapshotDirectory(
            testClassName: "HomeViewSnapshotTests",
            testName: testName,
            file: file
        )

        let failure = verifySnapshot(
            of: view,
            as: .image(
                precision: 0.96,
                perceptualPrecision: 0.97,
                layout: .device(config: .iPhone13)
            ),
            snapshotDirectory: snapshotDirectory,
            file: file,
            testName: testName,
            line: line
        )

        #expect(failure == nil, "\(failure ?? "")")
    }
}

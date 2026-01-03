//
//  MockWordLoader.swift
//  WordFeature
//
//  Created by Anthony on 3/1/26.
//

import Foundation

public final class MockWordLoader: WordLoaderProtocol, @unchecked Sendable {
    public enum MockError: LocalizedError {
        case failed

        public var errorDescription: String? {
            switch self {
            case .failed:
                return "Failed to load words. Please check your connection and try again."
            }
        }
    }

    public var delay: Duration
    public var wordsPerLoad: Int
    public var shouldFail: Bool

    public init(
        delay: Duration = .milliseconds(500),
        wordsPerLoad: Int = 10,
        shouldFail: Bool = false
    ) {
        self.delay = delay
        self.wordsPerLoad = wordsPerLoad
        self.shouldFail = shouldFail
    }

    public func load() async throws -> [Word] {
        try await Task.sleep(for: delay)

        if shouldFail {
            throw MockError.failed
        }

        return Word.randomMocks(count: wordsPerLoad)
    }
}

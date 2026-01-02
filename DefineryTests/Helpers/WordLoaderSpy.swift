//
//  WordLoaderSpy.swift
//  DefineryTests
//
//  Created by Anthony on 2/1/26.
//

import Foundation
import WordFeature

final class WordLoaderSpy: WordLoaderProtocol, @unchecked Sendable {
    private var result: Result<[Word], Error>?
    private(set) var loadCallCount = 0

    func load() async throws -> [Word] {
        loadCallCount += 1
        return try result.evaluate()
    }

    func complete(with result: Result<[Word], Error>) {
        self.result = result
    }
}

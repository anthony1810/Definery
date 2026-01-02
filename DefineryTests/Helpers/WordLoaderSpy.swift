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

    func load() async throws -> [Word] {
        try result.evaluate()
    }

    func complete(with result: Result<[Word], Error>) {
        self.result = result
    }
}

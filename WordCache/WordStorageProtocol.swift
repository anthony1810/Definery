//
//  WordStorageProtocol.swift
//  WordCache
//
//  Created by Anthony on 1/1/26.
//

import Foundation

public protocol WordStorageProtocol: Sendable {
    func deleteCachedWords() async throws
    func insertCache(words: [LocalWord]) async throws
    func retrieveWords() async throws -> [LocalWord]
}

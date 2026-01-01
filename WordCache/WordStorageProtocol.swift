//
//  WordStorageProtocol.swift
//  WordCache
//
//  Created by Anthony on 1/1/26.
//

import Foundation
import WordFeature

public protocol WordStorageProtocol: Sendable {
    func deleteCachedWords() async throws
    func insertCache(words: [Word]) async throws
    func retrieveWords() async throws -> [Word]
}

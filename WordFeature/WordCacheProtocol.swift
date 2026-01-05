//
//  WordCacheProtocol.swift
//  WordFeature
//
//  Created by Anthony on 31/12/25.
//

public protocol WordCacheProtocol: Sendable {
    func save(_ words: [Word]) async throws
}

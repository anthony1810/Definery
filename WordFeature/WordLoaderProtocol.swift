//
//  WordLoaderProtocol.swift
//  WordFeature
//
//  Created by Anthony on 31/12/25.
//

public protocol WordLoaderProtocol: Sendable {
    func load() async throws -> [Word]
}

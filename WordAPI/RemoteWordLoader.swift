//
//  RemoteWordLoader.swift
//  WordAPI
//
//  Created by Anthony on 31/12/25.
//

import Foundation
import WordFeature

public final class RemoteWordLoader: WordLoaderProtocol, Sendable {
    private let url: URL
    private let client: HTTPClient

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    public func load() async throws -> [Word] {
        let (data, response): (Data, HTTPURLResponse)

        do {
            (data, response) = try await client.get(from: url)
        } catch {
            throw Error.connectivity
        }

        do {
            return try WordMapper.map(data, from: response)
        } catch {
            throw Error.invalidData
        }
    }
}

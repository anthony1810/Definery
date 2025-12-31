//
//  URLSessionHTTPClient.swift
//  WordAPI
//
//  Created by Anthony on 31/12/25.
//

import Foundation

public final class URLSessionHTTPClient: HTTPClient {

    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public enum Error: Swift.Error {
        case invalidResponse
    }

    public func get(from url: URL) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw Error.invalidResponse
        }

        return (data, httpResponse)
    }
}

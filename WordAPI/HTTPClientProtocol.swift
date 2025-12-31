//
//  HTTPClientProtocol.swift
//  WordAPI
//
//  Created by Anthony on 31/12/25.
//

import Foundation

public protocol HTTPClient: Sendable {
    func get(from url: URL) async throws -> (Data, HTTPURLResponse)
}

//
//  WordsEndpoint.swift
//  WordAPI
//
//  Created by Anthony on 31/12/25.
//

import Foundation

public enum WordsEndpoint {
    case randomWords(count: Int, language: String)
    case definition(word: String, language: String)

    public func url(baseURL: URL) -> URL {
        switch self {
        case let .randomWords(count, language):
            var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
            components.path = "/word"
            components.queryItems = [
                URLQueryItem(name: "number", value: "\(count)"),
                URLQueryItem(name: "lang", value: language)
            ]
            return components.url!

        case let .definition(word, language):
            var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
            components.path = "/api/v2/entries/\(language)/\(word)"
            return components.url!
        }
    }
}

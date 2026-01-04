//
//  RemoteWordLoader.swift
//  WordAPI
//
//  Created by Anthony on 31/12/25.
//

import Foundation
import WordFeature

public final class RemoteWordLoader: WordLoaderProtocol, Sendable {
    private let client: HTTPClient
    private let randomWordsURL: URL
    private let definitionBaseURL: URL
    private let language: String

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public init(
        client: HTTPClient,
        randomWordsURL: URL,
        definitionBaseURL: URL,
        language: String
    ) {
        self.client = client
        self.randomWordsURL = randomWordsURL
        self.definitionBaseURL = definitionBaseURL
        self.language = language
    }

    public func load() async throws -> [Word] {
        let (data, res): (Data, HTTPURLResponse)
        do {
            (data, res) = try await client.get(from: randomWordsURL)
        } catch {
            throw Error.connectivity
        }

        guard let wordStrings = try? RandomWordMapper.map(data, from: res)
        else { throw Error.invalidData }

        let language = self.language
        let definitionBaseURL = self.definitionBaseURL
        return await withTaskGroup(of: Word?.self) { group in
            for word in wordStrings {
                group.addTask {
                    let url = WordsEndpoint.definition(word: word, language: language)
                        .url(baseURL: definitionBaseURL)
                    
                    guard let (defData, defRes) = try? await self.client.get(from: url),
                          let defWord = try? DefinitionMapper.map(defData, from: defRes, language: language)
                    else { return nil }

                    return defWord
                }
            }

            var words: [Word] = []
            for await word in group {
                if let word = word {
                    words.append(word)
                }
            }

            return words
        }
    }
}

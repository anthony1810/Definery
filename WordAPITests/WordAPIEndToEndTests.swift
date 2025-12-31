//
//  WordAPIEndToEndTests.swift
//  WordAPITests
//
//  Created by Anthony on 31/12/25.
//

import Testing
import Foundation
import WordAPI
import WordFeature

struct WordAPIEndToEndTests {

    // MARK: - Dictionary API End-to-End Tests

    @Test func getWordDefinition_deliversDefinitionForKnownWord() async throws {
        let client = makeEphemeralClient()
        let url = WordsEndpoint.definition(word: "hello", language: "en")
            .url(baseURL: URL(string: "https://api.dictionaryapi.dev")!)

        let (data, response) = try await client.get(from: url)

        #expect(response.statusCode == 200)
        #expect(!data.isEmpty)

        // Verify the response contains expected structure
        let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]]
        #expect(json != nil)
        #expect(json?.isEmpty == false)

        // Verify first result has the word "hello"
        let firstResult = json?.first
        #expect(firstResult?["word"] as? String == "hello")

        // Verify it has meanings
        let meanings = firstResult?["meanings"] as? [[String: Any]]
        #expect(meanings?.isEmpty == false)
    }

    @Test func getWordDefinition_deliversErrorForUnknownWord() async throws {
        let client = makeEphemeralClient()
        let url = WordsEndpoint.definition(word: "asdfghjklzxcvbnm", language: "en")
            .url(baseURL: URL(string: "https://api.dictionaryapi.dev")!)

        let (_, response) = try await client.get(from: url)

        #expect(response.statusCode == 404)
    }

    // MARK: - Random Word API End-to-End Tests

    @Test func getRandomWords_deliversWordsArray() async throws {
        let client = makeEphemeralClient()
        let url = WordsEndpoint.randomWords(count: 5, language: "en")
            .url(baseURL: URL(string: "https://random-word-api.herokuapp.com")!)

        let (data, response) = try await client.get(from: url)

        #expect(response.statusCode == 200)
        #expect(!data.isEmpty)

        // Verify the response is an array of strings
        let words = try JSONSerialization.jsonObject(with: data) as? [String]
        #expect(words != nil)
        #expect(words?.count == 5)
    }

    // MARK: - Helpers

    private func makeEphemeralClient() -> HTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        return URLSessionHTTPClient(session: URLSession(configuration: configuration))
    }
}

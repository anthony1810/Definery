//
//  WordsEndpointTests.swift
//  WordAPITests
//
//  Created by Anthony on 31/12/25.
//

import Testing
import Foundation
@testable import WordAPI

struct WordsEndpointTests {

    // MARK: - Random Words Endpoint Tests

    @Test func randomWords_endpointURL() {
        let baseURL = URL(string: "https://random-word-api.herokuapp.com")!
        let sut = WordsEndpoint.randomWords(count: 20, language: "en").url(baseURL: baseURL)

        #expect(sut.scheme == "https")
        #expect(sut.host == "random-word-api.herokuapp.com")
        #expect(sut.path == "/word")
    }

    @Test func randomWords_endpointURLWithCountParameter() {
        let baseURL = URL(string: "https://random-word-api.herokuapp.com")!
        let sut = WordsEndpoint.randomWords(count: 20, language: "en").url(baseURL: baseURL)

        #expect(sut.query?.contains("number=20") == true)
    }

    @Test func randomWords_endpointURLWithLanguageParameter() {
        let baseURL = URL(string: "https://random-word-api.herokuapp.com")!
        let sut = WordsEndpoint.randomWords(count: 10, language: "es").url(baseURL: baseURL)

        #expect(sut.query?.contains("lang=es") == true)
    }

    @Test func randomWords_endpointURLWithDifferentCount() {
        let baseURL = URL(string: "https://random-word-api.herokuapp.com")!
        let sut = WordsEndpoint.randomWords(count: 50, language: "en").url(baseURL: baseURL)

        #expect(sut.query?.contains("number=50") == true)
    }

    // MARK: - Definition Endpoint Tests (Wiktionary API)

    @Test func definition_endpointURL() {
        let baseURL = URL(string: "https://en.wiktionary.org")!
        let sut = WordsEndpoint.definition(word: "hello", language: "en").url(baseURL: baseURL)

        #expect(sut.scheme == "https")
        #expect(sut.host == "en.wiktionary.org")
        #expect(sut.path == "/w/api.php")
    }

    @Test func definition_endpointURLWithRequiredQueryParameters() {
        let baseURL = URL(string: "https://en.wiktionary.org")!
        let sut = WordsEndpoint.definition(word: "hello", language: "en").url(baseURL: baseURL)

        #expect(sut.query?.contains("action=parse") == true)
        #expect(sut.query?.contains("format=json") == true)
        #expect(sut.query?.contains("prop=wikitext") == true)
    }

    @Test func definition_endpointURLWithWordParameter() {
        let baseURL = URL(string: "https://en.wiktionary.org")!
        let sut = WordsEndpoint.definition(word: "hello", language: "en").url(baseURL: baseURL)

        #expect(sut.query?.contains("page=hello") == true)
    }

    @Test func definition_endpointURLWithDifferentWord() {
        let baseURL = URL(string: "https://en.wiktionary.org")!
        let sut = WordsEndpoint.definition(word: "world", language: "en").url(baseURL: baseURL)

        #expect(sut.query?.contains("page=world") == true)
    }
}

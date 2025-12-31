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

    // MARK: - Definition Endpoint Tests

    @Test func definition_endpointURL() {
        let baseURL = URL(string: "https://api.dictionaryapi.dev")!
        let sut = WordsEndpoint.definition(word: "hello", language: "en").url(baseURL: baseURL)

        #expect(sut.scheme == "https")
        #expect(sut.host == "api.dictionaryapi.dev")
        #expect(sut.path == "/api/v2/entries/en/hello")
    }

    @Test func definition_endpointURLWithDifferentWord() {
        let baseURL = URL(string: "https://api.dictionaryapi.dev")!
        let sut = WordsEndpoint.definition(word: "world", language: "en").url(baseURL: baseURL)

        #expect(sut.path == "/api/v2/entries/en/world")
    }

    @Test func definition_endpointURLWithDifferentLanguage() {
        let baseURL = URL(string: "https://api.dictionaryapi.dev")!
        let sut = WordsEndpoint.definition(word: "hola", language: "es").url(baseURL: baseURL)

        #expect(sut.path == "/api/v2/entries/es/hola")
    }
}

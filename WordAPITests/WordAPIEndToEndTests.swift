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

final class WordAPIEndToEndTests {
    private var sutTracker: MemoryLeakTracker<SUT>?
    
    deinit {
        sutTracker?.verify()
    }
    
    // MARK: - Random Word API End-to-End Tests
    @Test func getRandomWords_deliversMappableResponse() async throws {
        let sut = makeSUT()
        let url = WordsEndpoint.randomWords(count: 5, language: "en")
            .url(baseURL: URL(string: "https://random-word-api.herokuapp.com")!)
        
        let (data, response) = try await sut.client.get(from: url)
        
        let words = try RandomWordMapper.map(data, from: response)
        
        #expect(words.count == 5)
        #expect(words.allSatisfy { !$0.isEmpty })
    }
    
    // MARK: - Dictionary API End-to-End Tests
    @Test func getWordDefinition_deliversMappableResponse() async throws {
        let sut = makeSUT()
        let url = WordsEndpoint.definition(word: "hello", language: "en")
            .url(baseURL: URL(string: "https://api.dictionaryapi.dev")!)
        
        let (data, response) = try await sut.client.get(from: url)
        
        let word = try DefinitionMapper.map(data, from: response, language: "en")
        
        #expect(word.text == "hello")
        #expect(word.language == "en")
        #expect(!word.meanings.isEmpty)
    }
    
    @Test func getWordDefinition_throwsForUnknownWord() async throws {
        let sut = makeSUT()
        let url = WordsEndpoint.definition(word: "asdfghjklzxcvbnm", language: "en")
            .url(baseURL: URL(string: "https://api.dictionaryapi.dev")!)

        let (data, response) = try await sut.client.get(from: url)

        #expect(throws: DefinitionMapper.Error.invalidData) {
            try DefinitionMapper.map(data, from: response, language: "en")
        }
    }


    // MARK: - Multi-Language Support Tests

    @Test(arguments: randomWordAPILanguages)
    func getRandomWords_deliversResultsForAllSupportedLanguages(language: String) async throws {
        let sut = makeSUT()
        let url = WordsEndpoint.randomWords(count: 3, language: language)
            .url(baseURL: URL(string: "https://random-word-api.herokuapp.com")!)

        let (data, response) = try await sut.client.get(from: url)

        let words = try RandomWordMapper.map(data, from: response)

        #expect(words.count == 3, "Expected 3 words for language '\(language)', got \(words.count)")
        #expect(words.allSatisfy { !$0.isEmpty }, "Expected non-empty words for language '\(language)'")
    }

    @Test(arguments: dictionaryAPITestWords)
    func getWordDefinition_deliversResultsForAllSupportedLanguages(testCase: (language: String, word: String)) async throws {
        let sut = makeSUT()
        let url = WordsEndpoint.definition(word: testCase.word, language: testCase.language)
            .url(baseURL: URL(string: "https://api.dictionaryapi.dev")!)

        let (data, response) = try await sut.client.get(from: url)

        let word = try DefinitionMapper.map(data, from: response, language: testCase.language)

        #expect(word.text == testCase.word, "Expected word '\(testCase.word)' for language '\(testCase.language)'")
        #expect(word.language == testCase.language)
        #expect(!word.meanings.isEmpty, "Expected meanings for '\(testCase.word)' in '\(testCase.language)'")
    }
}

// MARK: - Test Data

// Random Word API supported languages (from https://random-word-api.herokuapp.com/languages)
// Note: Portuguese uses "pt-br" not "pt"
private let randomWordAPILanguages = ["en", "es", "it", "de", "fr", "zh", "pt-br"]

// Dictionary API (dictionaryapi.dev) only supports English
private let dictionaryAPILanguages = ["en"]

private let dictionaryAPITestWords: [(language: String, word: String)] = [
    ("en", "hello")
]

// MARK: - Helpers

extension WordAPIEndToEndTests {
    final class SUT {
        let client: URLSessionHTTPClient

        init(client: URLSessionHTTPClient) {
            self.client = client
        }
    }

    private func makeSUT(
        fileId: String = #fileID,
        filePath: String = #filePath,
        line: Int = #line,
        column: Int = #column
    ) -> SUT {
        let configuration = URLSessionConfiguration.ephemeral
        let client = URLSessionHTTPClient(session: URLSession(configuration: configuration))
        let sut = SUT(client: client)

        sutTracker = MemoryLeakTracker(
            instance: sut,
            sourceLocation: SourceLocation(
                fileID: fileId,
                filePath: filePath,
                line: line,
                column: column
            )
        )

        return sut
    }
}

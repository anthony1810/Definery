//
//  RemoteWordLoaderTests.swift
//  WordAPITests
//
//  Created by Anthony on 31/12/25.
//

import Testing
import Foundation
@testable import WordAPI
import WordFeature

final class RemoteWordLoaderTests {
    private var sutTracker: MemoryLeakTracker<SUT>?

    deinit {
        sutTracker?.verify()
    }

    // MARK: - Init Tests

    @Test func init_doesNotRequestDataFromURL() async {
        let sut = makeSUT()

        let urls = await sut.client.requestedURLs
        #expect(urls.isEmpty)
    }

    // MARK: - Load Tests - Random Words Request

    @Test func load_requestsRandomWordsFromURL() async throws {
        let randomWordsURL = anyURL()
        let sut = makeSUT(randomWordsURL: randomWordsURL)
        sut.client.complete(withStatusCode: 200, data: makeWordsJSON([]))

        _ = try? await sut.loader.load()

        let urls = await sut.client.requestedURLs
        #expect(urls == [randomWordsURL])
    }

    @Test func load_deliversConnectivityErrorOnRandomWordsClientError() async {
        let sut = makeSUT()
        sut.client.complete(with: anyNSError())

        await #expect(throws: RemoteWordLoader.Error.connectivity) {
            try await sut.loader.load()
        }
    }

    @Test func load_deliversInvalidDataErrorOnInvalidRandomWordsResponse() async {
        let sut = makeSUT()
        sut.client.complete(withStatusCode: 200, data: Data("invalid".utf8))

        await #expect(throws: RemoteWordLoader.Error.invalidData) {
            try await sut.loader.load()
        }
    }

    // MARK: - Load Tests - Definition Requests

    @Test func load_requestsDefinitionForEachRandomWord() async throws {
        let definitionBaseURL = anyURL()
        let language = anyLanguageCode()
        let sut = makeSUT(definitionBaseURL: definitionBaseURL, language: language)
        let words = ["hello", "world"]

        sut.client.complete(withStatusCode: 200, data: makeWordsJSON(words), at: 0)
        sut.client.complete(withStatusCode: 200, data: Data(), at: 1)
        sut.client.complete(withStatusCode: 200, data: Data(), at: 2)

        _ = try? await sut.loader.load()

        let expectedHelloURL = WordsEndpoint.definition(word: "hello", language: language)
            .url(baseURL: definitionBaseURL)
        let expectedWorldURL = WordsEndpoint.definition(word: "world", language: language)
            .url(baseURL: definitionBaseURL)

        let urls = await sut.client.requestedURLs
        #expect(urls.contains(expectedHelloURL))
        #expect(urls.contains(expectedWorldURL))
    }

    @Test func load_deliversWordsOnSuccessfulResponses() async throws {
        let sut = makeSUT()

        sut.client.complete(withStatusCode: 200, data: makeWordsJSON(["hello"]), at: 0)
        sut.client.complete(
            withStatusCode: 200,
            data: makeWiktionaryJSON(
                word: "hello",
                partOfSpeech: "Noun",
                definition: "A greeting"
            ),
            at: 1
        )

        let result = try await sut.loader.load()

        #expect(result.count == 1)
        #expect(result[0].text == "hello")
        #expect(result[0].meanings[0].partOfSpeech == "Noun")
        #expect(result[0].meanings[0].definition == "A greeting")
    }

    @Test func load_skipsWordsWithFailedDefinitions() async throws {
        let sut = makeSUT()

        sut.client.complete(withStatusCode: 200, data: makeWordsJSON(["hello", "word"]), at: 0)
        sut.client.complete(with: anyNSError(), at: 1)
        sut.client.complete(
            withStatusCode: 200,
            data: makeWiktionaryJSON(
                word: "word",
                partOfSpeech: "Noun",
                definition: "The earth"
            ),
            at: 2
        )

        let result = try await sut.loader.load()

        #expect(result.count == 1)
        #expect(result[0].text == "word")
        #expect(result[0].meanings[0].partOfSpeech == "Noun")
        #expect(result[0].meanings[0].definition == "The earth")
    }
    
    @Test func load_deliversEmptyArrayWhenAllDefinitionsFail() async throws {
        let sut = makeSUT()
        
        sut.client.complete(withStatusCode: 200, data: makeWordsJSON(["hello", "world"]), at: 0)
        sut.client.complete(with: anyNSError(), at: 1)
        sut.client.complete(with: anyNSError(), at: 2)
        
        let result = try await sut.loader.load()
        
        #expect(result.isEmpty)
    }
}

// MARK: - Helpers

extension RemoteWordLoaderTests {
    final class SUT {
        let loader: RemoteWordLoader
        let client: HTTPClientSpy

        init(loader: RemoteWordLoader, client: HTTPClientSpy) {
            self.loader = loader
            self.client = client
        }
    }

    private func makeSUT(
        randomWordsURL: URL = anyURL(),
        definitionBaseURL: URL = anyURL(),
        language: String = anyLanguageCode(),
        fileId: String = #fileID,
        filePath: String = #filePath,
        line: Int = #line,
        column: Int = #column
    ) -> SUT {
        let client = HTTPClientSpy()
        let loader = RemoteWordLoader(
            client: client,
            randomWordsURL: randomWordsURL,
            definitionBaseURL: definitionBaseURL,
            language: language
        )
        let sut = SUT(loader: loader, client: client)

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

    // MARK: - JSON Helpers (Wiktionary format)

    private func makeWiktionaryJSON(
        word: String,
        language: String = "en",
        partOfSpeech: String,
        definition: String
    ) -> Data {
        let languageName = language == "en" ? "English" : language
        let wikitext = """
        ==\(languageName)==

        ===\(partOfSpeech)===
        {{\(language)-\(partOfSpeech.lowercased())}}

        # \(definition)
        """

        let json: [String: Any] = [
            "parse": [
                "title": word,
                "pageid": 12345,
                "wikitext": [
                    "*": wikitext
                ]
            ]
        ]
        return try! JSONSerialization.data(withJSONObject: json)
    }
}

// MARK: - HTTPClientSpy

actor HTTPClientSpyStorage {
    var messages: [URL] = []
    var stubs: [Int: Result<(Data, HTTPURLResponse), Error>] = [:]

    func appendMessage(_ url: URL) -> Int {
        let index = messages.count
        messages.append(url)
        return index
    }

    func setStub(_ result: Result<(Data, HTTPURLResponse), Error>, at index: Int) {
        stubs[index] = result
    }

    func getStub(at index: Int) -> Result<(Data, HTTPURLResponse), Error>? {
        stubs[index]
    }
}

final class HTTPClientSpy: HTTPClient, @unchecked Sendable {
    private let storage = HTTPClientSpyStorage()
    // Synchronous storage for stubs set before async calls
    private var syncStubs: [Int: Result<(Data, HTTPURLResponse), Error>] = [:]

    var requestedURLs: [URL] {
        get async {
            await storage.messages
        }
    }

    func complete(with error: Error, at index: Int = 0) {
        syncStubs[index] = .failure(error)
    }

    func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
        let response = HTTPURLResponse(statusCode: code)
        syncStubs[index] = .success((data, response))
    }

    func get(from url: URL) async throws -> (Data, HTTPURLResponse) {
        let index = await storage.appendMessage(url)

        guard let stub = syncStubs[index] else {
            throw anyNSError()
        }

        return try stub.get()
    }
}

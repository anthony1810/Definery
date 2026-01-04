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

        #expect(sut.client.requestedURLs.isEmpty)
    }

    // MARK: - Load Tests - Random Words Request

    @Test func load_requestsRandomWordsFromURL() async throws {
        let randomWordsURL = anyURL()
        let sut = makeSUT(randomWordsURL: randomWordsURL)
        sut.client.complete(withStatusCode: 200, data: makeWordsJSON([]))

        _ = try? await sut.loader.load()

        #expect(sut.client.requestedURLs == [randomWordsURL])
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
        let sut = makeSUT(definitionBaseURL: definitionBaseURL)
        let words = ["hello", "world"]
        
        sut.client.complete(withStatusCode: 200, data: makeWordsJSON(words), at: 0)
        sut.client.complete(withStatusCode: 200, data: Data(), at: 1)
        sut.client.complete(withStatusCode: 200, data: Data(), at: 2)
        
        _ = try? await sut.loader.load()
        
        #expect(sut.client.requestedURLs.contains(definitionBaseURL.appending(path: "hello")))
        #expect(sut.client.requestedURLs.contains(definitionBaseURL.appending(path: "world")))
    }

    @Test func load_deliversWordsOnSuccessfulResponses() async throws {
        let sut = makeSUT()
        
        sut.client.complete(withStatusCode: 200, data: makeWordsJSON(["hello"]), at: 0)
        sut.client.complete(
            withStatusCode: 200,
            data: makeDefinitionJSON(
                word: "hello",
                phonetic: "/həˈloʊ/",
                meanings: [
                    makeMeaningJSON(
                        partOfSpeech: "noun",
                        definition: "A greeting"
                    )
                ]
            ),
            at: 1
        )
        
        let result = try await sut.loader.load()
        
        #expect(result.count == 1)
        #expect(result[0].text == "hello")
        #expect(result[0].phonetic == "/həˈloʊ/")
        #expect(result[0].meanings[0].partOfSpeech == "noun")
        #expect(result[0].meanings[0].definition == "A greeting")
    }

    @Test func load_skipsWordsWithFailedDefinitions() async throws {
        let sut = makeSUT()
        
        sut.client.complete(withStatusCode: 200, data: makeWordsJSON(["hello", "word"]), at: 0)
        sut.client.complete(with: anyNSError(), at: 1)
        sut.client.complete(
            withStatusCode: 200,
            data: makeDefinitionJSON(
                word: "word",
                meanings: [
                    makeMeaningJSON(partOfSpeech: "noun", definition: "The earth")
                ]
            ),
            at: 2
        )
        
        let result = try await sut.loader.load()
        
        #expect(result.count == 1)
        #expect(result[0].text == "word")
        #expect(result[0].meanings[0].partOfSpeech == "noun")
        #expect(result[0].meanings[0].definition == "The earth")
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

    // MARK: - JSON Helpers

    private func makeDefinitionJSON(
        word: String,
        phonetic: String? = nil,
        meanings: [[String: Any]]
    ) -> Data {
        var wordJSON: [String: Any] = ["word": word, "meanings": meanings]
        if let phonetic { wordJSON["phonetic"] = phonetic }
        return try! JSONSerialization.data(withJSONObject: [wordJSON])
    }

    private func makeMeaningJSON(
        partOfSpeech: String,
        definition: String,
        example: String? = nil
    ) -> [String: Any] {
        var defJSON: [String: Any] = ["definition": definition]
        if let example { defJSON["example"] = example }
        return ["partOfSpeech": partOfSpeech, "definitions": [defJSON]]
    }
}

// MARK: - HTTPClientSpy

final class HTTPClientSpy: HTTPClient, @unchecked Sendable {
    private var messages: [URL] = []
    private var stubs: [Int: Result<(Data, HTTPURLResponse), Error>] = [:]

    var requestedURLs: [URL] {
        messages
    }

    func complete(with error: Error, at index: Int = 0) {
        stubs[index] = .failure(error)
    }

    func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
        let response = HTTPURLResponse(statusCode: code)
        stubs[index] = .success((data, response))
    }

    func get(from url: URL) async throws -> (Data, HTTPURLResponse) {
        let index = messages.count
        messages.append(url)

        guard let stub = stubs[index] else {
            throw anyNSError()
        }

        return try stub.get()
    }
}

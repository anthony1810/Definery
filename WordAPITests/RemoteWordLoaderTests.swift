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

struct RemoteWordLoaderTests {

    // MARK: - Init Tests

    @Test func init_doesNotRequestDataFromURL() async {
        let (_, client) = makeSUT()

        #expect(client.requestedURLs.isEmpty)
    }

    // MARK: - Load Tests

    @Test func load_requestsDataFromURL() async throws {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)

        _ = try? await sut.load()

        #expect(client.requestedURLs == [url])
    }

    @Test func load_requestsDataFromURLTwice() async throws {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)

        _ = try? await sut.load()
        _ = try? await sut.load()

        #expect(client.requestedURLs == [url, url])
    }

    @Test func load_deliversErrorOnClientError() async {
        let (sut, client) = makeSUT()
        client.stub = .failure(anyNSError())

        await #expect(throws: RemoteWordLoader.Error.connectivity) {
            try await sut.load()
        }
    }

    @Test func load_deliversErrorOnNon200HTTPResponse() async {
        let (sut, client) = makeSUT()

        let samples = [199, 201, 300, 400, 500]
        for statusCode in samples {
            client.stub = .success((anyData(), HTTPURLResponse(statusCode: statusCode)))

            await #expect(throws: RemoteWordLoader.Error.invalidData) {
                try await sut.load()
            }
        }
    }

    @Test func load_deliversErrorOn200HTTPResponseWithInvalidJSON() async {
        let (sut, client) = makeSUT()
        let invalidJSON = Data("invalid json".utf8)
        client.stub = .success((invalidJSON, HTTPURLResponse(statusCode: 200)))

        await #expect(throws: RemoteWordLoader.Error.invalidData) {
            try await sut.load()
        }
    }

    @Test func load_deliversNoItemsOn200HTTPResponseWithEmptyJSONArray() async throws {
        let (sut, client) = makeSUT()
        let emptyListJSON = makeItemsJSON([])
        client.stub = .success((emptyListJSON, HTTPURLResponse(statusCode: 200)))

        let result = try await sut.load()

        #expect(result == [])
    }

    @Test func load_deliversItemsOn200HTTPResponseWithJSONItems() async throws {
        let (sut, client) = makeSUT()

        let item1 = makeItem(
            id: UUID(),
            text: "hello",
            language: "en",
            phonetic: "həˈləʊ",
            meanings: [
                makeMeaning(partOfSpeech: "noun", definition: "A greeting", example: "Hello there!")
            ]
        )

        let item2 = makeItem(
            id: UUID(),
            text: "world",
            language: "en",
            phonetic: nil,
            meanings: []
        )

        let json = makeItemsJSON([item1.json, item2.json])
        client.stub = .success((json, HTTPURLResponse(statusCode: 200)))

        let result = try await sut.load()

        #expect(result == [item1.model, item2.model])
    }

    // MARK: - Helpers

    private func makeSUT(
        url: URL = URL(string: "https://any-url.com")!
    ) -> (sut: RemoteWordLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteWordLoader(url: url, client: client)
        return (sut, client)
    }

    private func makeItem(
        id: UUID,
        text: String,
        language: String,
        phonetic: String?,
        meanings: [(model: Meaning, json: [String: Any])]
    ) -> (model: Word, json: [String: Any]) {
        let model = Word(
            id: id,
            text: text,
            language: language,
            phonetic: phonetic,
            meanings: meanings.map { $0.model }
        )

        var json: [String: Any] = [
            "id": id.uuidString,
            "text": text,
            "language": language,
            "meanings": meanings.map { $0.json }
        ]

        if let phonetic = phonetic {
            json["phonetic"] = phonetic
        }

        return (model, json)
    }

    private func makeMeaning(
        partOfSpeech: String,
        definition: String,
        example: String?
    ) -> (model: Meaning, json: [String: Any]) {
        let model = Meaning(
            partOfSpeech: partOfSpeech,
            definition: definition,
            example: example
        )

        var json: [String: Any] = [
            "partOfSpeech": partOfSpeech,
            "definition": definition
        ]

        if let example = example {
            json["example"] = example
        }

        return (model, json)
    }

    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }

    private func anyData() -> Data {
        Data("any data".utf8)
    }

    private func anyNSError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
}

// MARK: - HTTPClientSpy

final class HTTPClientSpy: HTTPClient, @unchecked Sendable {
    var requestedURLs: [URL] = []
    var stub: Result<(Data, HTTPURLResponse), Error> = .success((Data(), HTTPURLResponse()))

    func get(from url: URL) async throws -> (Data, HTTPURLResponse) {
        requestedURLs.append(url)
        return try stub.get()
    }
}

// MARK: - HTTPURLResponse Extension

extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: URL(string: "https://any-url.com")!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}

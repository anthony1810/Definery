//
//  WordMapperTests.swift
//  WordAPITests
//
//  Created by Anthony on 31/12/25.
//

import Testing
import Foundation
@testable import WordAPI
import WordFeature

struct WordMapperTests {

    @Test func map_throwsErrorOnNon200HTTPResponse() throws {
        let samples = [199, 201, 300, 400, 500]

        for statusCode in samples {
            #expect(throws: RemoteWordLoader.Error.invalidData) {
                try WordMapper.map(anyData(), from: HTTPURLResponse(statusCode: statusCode))
            }
        }
    }

    @Test func map_throwsErrorOn200HTTPResponseWithInvalidJSON() {
        let invalidJSON = Data("invalid json".utf8)

        #expect(throws: RemoteWordLoader.Error.invalidData) {
            try WordMapper.map(invalidJSON, from: HTTPURLResponse(statusCode: 200))
        }
    }

    @Test func map_deliversNoItemsOn200HTTPResponseWithEmptyJSONArray() throws {
        let emptyListJSON = makeItemsJSON([])

        let result = try WordMapper.map(emptyListJSON, from: HTTPURLResponse(statusCode: 200))

        #expect(result == [])
    }

    @Test func map_deliversItemsOn200HTTPResponseWithJSONItems() throws {
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

        let result = try WordMapper.map(json, from: HTTPURLResponse(statusCode: 200))

        #expect(result == [item1.model, item2.model])
    }

    @Test func map_deliversItemWithMultipleMeanings() throws {
        let item = makeItem(
            id: UUID(),
            text: "run",
            language: "en",
            phonetic: "rʌn",
            meanings: [
                makeMeaning(partOfSpeech: "verb", definition: "Move at a speed faster than a walk", example: "I run every morning"),
                makeMeaning(partOfSpeech: "noun", definition: "An act of running", example: nil)
            ]
        )

        let json = makeItemsJSON([item.json])

        let result = try WordMapper.map(json, from: HTTPURLResponse(statusCode: 200))

        #expect(result == [item.model])
        #expect(result.first?.meanings.count == 2)
    }

    // MARK: - Helpers

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
}

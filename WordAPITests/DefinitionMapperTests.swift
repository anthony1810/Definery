//
//  DefinitionMapperTests.swift
//  WordAPITests
//
//  Created by Anthony on 4/1/26.
//

import Testing
import Foundation
@testable import WordAPI
import WordFeature

struct DefinitionMapperTests {
    
    @Test func map_throwsErrorOnNon200HTTPResponse() throws {
        let statusCodes = [199, 201, 300, 400, 500]
        
        for statusCode in statusCodes {
            #expect(throws: DefinitionMapper.Error.invalidData) {
                try DefinitionMapper.map(
                    anyData(),
                    from: HTTPURLResponse(statusCode: statusCode),
                    language: anyLanguageCode()
                )
            }
        }
    }
    
    @Test func map_throwsErrorOn200HTTPResponseWithInvalidJSON() throws {
        let invalidJSONData = "invalid json".data(using: .utf8)!
        
        #expect(throws: DefinitionMapper.Error.invalidData) {
            try DefinitionMapper.map(
                invalidJSONData,
                from: HTTPURLResponse(statusCode: 200),
                language: anyLanguageCode()
            )
        }
    }
    
    @Test func map_throwsErrorOn200HTTPResponseWithEmptyArray() throws {
        let emptyListJSON = makeRootJSON([])
        
        #expect(throws: DefinitionMapper.Error.invalidData) {
            try DefinitionMapper.map(
                emptyListJSON,
                from: HTTPURLResponse(statusCode: 200),
                language: anyLanguageCode()
            )
        }
    }
    
    @Test func map_deliversWordOn200HTTPResponseWithValidJSON() throws {
        let language = "en"
        let definitionJSON = makeDefinitionJSON(definition: "A greeting", example: "Hello there!")
        let meaningJSON = makeMeaningJSON(partOfSpeech: "noun", definitions: [definitionJSON])
        let wordJSON = makeWordJSON(word: "hello", phonetic: "/həˈloʊ/", meanings: [meaningJSON])
        let json = makeRootJSON([wordJSON])
        
        let result = try DefinitionMapper.map(
            json,
            from: HTTPURLResponse(statusCode: 200),
            language: language
        )
        
        #expect(result.text == "hello")
        #expect(result.language == language)
        #expect(result.phonetic == "/həˈloʊ/")
        #expect(result.meanings.count == 1)
        #expect(result.meanings.first?.partOfSpeech == "noun")
        #expect(result.meanings.first?.definition == "A greeting")
        #expect(result.meanings.first?.example == "Hello there!")
    }
    
    @Test func map_deliversWordWithMultipleMeanings() throws {
        let language = "en"
        let nounDef = makeDefinitionJSON(definition: "An act of running", example: "Go for a run")
        let verbDef = makeDefinitionJSON(definition: "Move at a speed faster than a walk", example: "I run every morning")
        let nounMeaning = makeMeaningJSON(partOfSpeech: "noun", definitions: [nounDef])
        let verbMeaning = makeMeaningJSON(partOfSpeech: "verb", definitions: [verbDef])
        let wordJSON = makeWordJSON(word: "run", phonetic: "/rʌn/", meanings: [nounMeaning, verbMeaning])
        let json = makeRootJSON([wordJSON])
        
        let result = try DefinitionMapper.map(json, from: HTTPURLResponse(statusCode: 200), language: language)
        
        #expect(result.meanings[0].partOfSpeech == "noun")
        #expect(result.meanings[0].definition == "An act of running")
        #expect(result.meanings[0].example == "Go for a run")
        
        #expect(result.meanings[1].partOfSpeech == "verb")
        #expect(result.meanings[1].definition == "Move at a speed faster than a walk")
        #expect(result.meanings[1].example == "I run every morning")
    }
    
    @Test func map_deliversWordWithFirstDefinitionPerMeaning() throws {
        let language = "en"
        let firstDef = makeDefinitionJSON(definition: "First definition", example: "First example")
        let secondDef = makeDefinitionJSON(definition: "Second definition", example: "Second example")
        let meaningJSON = makeMeaningJSON(partOfSpeech: "noun", definitions: [firstDef, secondDef])
        let wordJSON = makeWordJSON(word: "test", meanings: [meaningJSON])
        let json = makeRootJSON([wordJSON])
        
        let result = try DefinitionMapper.map(json, from: HTTPURLResponse(statusCode: 200), language: language)
        
        #expect(result.meanings.count == 1)
        #expect(result.meanings[0].definition == "First definition")
        #expect(result.meanings[0].example == "First example")
    }
    
    @Test func map_deliversWordWithoutPhonetic() throws {
        let language = "en"
        let definitionJSON = makeDefinitionJSON(definition: "A test word")
        let meaningJSON = makeMeaningJSON(partOfSpeech: "noun", definitions: [definitionJSON])
        let wordJSON = makeWordJSON(word: "test", meanings: [meaningJSON])  // no phonetic
        let json = makeRootJSON([wordJSON])
        
        let result = try DefinitionMapper.map(json, from: HTTPURLResponse(statusCode: 200), language: language)
        
        #expect(result.phonetic == nil)
    }
    
    @Test func map_deliversWordWithDefinitionWithoutExample() throws {
        let language = "en"
        let definitionJSON = makeDefinitionJSON(definition: "A test word")  // no example
        let meaningJSON = makeMeaningJSON(partOfSpeech: "noun", definitions: [definitionJSON])
        let wordJSON = makeWordJSON(word: "test", meanings: [meaningJSON])
        let json = makeRootJSON([wordJSON])
        
        let result = try DefinitionMapper.map(json, from: HTTPURLResponse(statusCode: 200), language: language)
        
        #expect(result.meanings[0].example == nil)
    }
    
    // MARK: - Helpers
    // Expected JSON structure from Dictionary API:
    // [{
    //   "word": "hello",
    //   "phonetic": "/həˈloʊ/",
    //   "meanings": [{
    //     "partOfSpeech": "noun",
    //     "definitions": [{
    //       "definition": "A greeting",
    //       "example": "Hello there!"
    //     }]
    //   }]
    // }]
    
    private func makeWordJSON(
        word: String,
        phonetic: String? = nil,
        meanings: [[String: Any]]
    ) -> [String: Any] {
        [
            "word": word,
            "phonetic": phonetic,
            "meanings": meanings
        ].compactMapValues { $0 }
    }
    
    private func makeMeaningJSON(
        partOfSpeech: String,
        definitions: [[String: Any]]
    ) -> [String: Any] {
        [
            "partOfSpeech": partOfSpeech,
            "definitions": definitions
        ]
    }
    
    private func makeDefinitionJSON(
        definition: String,
        example: String? = nil
    ) -> [String: Any] {
        [
            "definition": definition,
            "example": example
        ].compactMapValues { $0 }
    }
    
    private func makeRootJSON(_ words: [[String: Any]]) -> Data {
        try! JSONSerialization.data(withJSONObject: words)
    }
}

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

    // MARK: - Error Cases

    @Test func map_throwsErrorOnNon200HTTPResponse() throws {
        let statusCodes = [199, 201, 300, 400, 500]

        for statusCode in statusCodes {
            #expect(throws: DefinitionMapper.Error.invalidData) {
                try DefinitionMapper.map(
                    anyData(),
                    from: HTTPURLResponse(statusCode: statusCode),
                    word: anyWord(),
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
                word: anyWord(),
                language: anyLanguageCode()
            )
        }
    }

    @Test func map_throwsErrorOn200HTTPResponseWithMissingPage() throws {
        let json = makeErrorJSON(code: "missingtitle", info: "The page you specified doesn't exist.")

        #expect(throws: DefinitionMapper.Error.wordNotFound) {
            try DefinitionMapper.map(
                json,
                from: HTTPURLResponse(statusCode: 200),
                word: "nonexistent",
                language: anyLanguageCode()
            )
        }
    }

    @Test func map_throwsErrorOn200HTTPResponseWithEmptyWikitext() throws {
        let json = makeWikitextJSON(title: "test", wikitext: "")

        #expect(throws: DefinitionMapper.Error.noDefinitionFound) {
            try DefinitionMapper.map(
                json,
                from: HTTPURLResponse(statusCode: 200),
                word: "test",
                language: anyLanguageCode()
            )
        }
    }

    // MARK: - English Word Parsing

    @Test func map_deliversWordWithSingleMeaning() throws {
        let wikitext = """
        ==English==

        ===Noun===
        {{en-noun}}

        # A greeting said when meeting someone.
        """
        let json = makeWikitextJSON(title: "hello", wikitext: wikitext)

        let result = try DefinitionMapper.map(
            json,
            from: HTTPURLResponse(statusCode: 200),
            word: "hello",
            language: "en"
        )

        #expect(result.text == "hello")
        #expect(result.language == "en")
        #expect(result.meanings.count == 1)
        #expect(result.meanings[0].partOfSpeech == "Noun")
        #expect(result.meanings[0].definition == "A greeting said when meeting someone.")
    }

    @Test func map_deliversWordWithMultipleMeanings() throws {
        let wikitext = """
        ==English==

        ===Noun===
        {{en-noun}}

        # An act of running.

        ===Verb===
        {{en-verb}}

        # To move swiftly on foot.
        """
        let json = makeWikitextJSON(title: "run", wikitext: wikitext)

        let result = try DefinitionMapper.map(
            json,
            from: HTTPURLResponse(statusCode: 200),
            word: "run",
            language: "en"
        )

        #expect(result.meanings.count == 2)
        #expect(result.meanings[0].partOfSpeech == "Noun")
        #expect(result.meanings[0].definition == "An act of running.")
        #expect(result.meanings[1].partOfSpeech == "Verb")
        #expect(result.meanings[1].definition == "To move swiftly on foot.")
    }

    @Test func map_deliversWordWithMultipleDefinitionsPerMeaning() throws {
        let wikitext = """
        ==English==

        ===Noun===
        {{en-noun}}

        # A greeting said when meeting someone.
        # A call for response.
        """
        let json = makeWikitextJSON(title: "hello", wikitext: wikitext)

        let result = try DefinitionMapper.map(
            json,
            from: HTTPURLResponse(statusCode: 200),
            word: "hello",
            language: "en"
        )

        #expect(result.meanings.count == 1)
        // Takes only the first definition per part of speech
        #expect(result.meanings[0].definition == "A greeting said when meeting someone.")
    }

    @Test func map_stripsWikiLinksFromDefinition() throws {
        let wikitext = """
        ==English==

        ===Verb===
        {{en-verb}}

        # To [[choose]]; to [[select]]; to [[pick]].
        """
        let json = makeWikitextJSON(title: "choose", wikitext: wikitext)

        let result = try DefinitionMapper.map(
            json,
            from: HTTPURLResponse(statusCode: 200),
            word: "choose",
            language: "en"
        )

        #expect(result.meanings[0].definition == "To choose; to select; to pick.")
    }

    @Test func map_extractsExampleFromUsageTemplate() throws {
        let wikitext = """
        ==English==

        ===Interjection===
        {{en-intj}}

        # A greeting said when meeting someone.
        #: {{ux|en|'''Hello''', everyone.}}
        """
        let json = makeWikitextJSON(title: "hello", wikitext: wikitext)

        let result = try DefinitionMapper.map(
            json,
            from: HTTPURLResponse(statusCode: 200),
            word: "hello",
            language: "en"
        )

        #expect(result.meanings[0].example == "Hello, everyone.")
    }

    @Test func map_extractsExampleFromRealWikitextFormat() throws {
        // Real Wiktionary format uses {{ng|...}} for definitions
        let wikitext = """
        ==English==

        ===Interjection===
        {{en-intj}}

        # {{ng|A [[greeting]] said when [[meet]]ing someone.}}
        #: {{ux|en|'''Hello''', everyone.}}
        """
        let json = makeWikitextJSON(title: "hello", wikitext: wikitext)

        let result = try DefinitionMapper.map(
            json,
            from: HTTPURLResponse(statusCode: 200),
            word: "hello",
            language: "en"
        )

        #expect(result.meanings[0].definition == "A greeting said when meeting someone.")
        #expect(result.meanings[0].example == "Hello, everyone.")
    }

    // MARK: - Chinese Word Parsing

    @Test func map_deliversChineseWordWithEnglishDefinition() throws {
        let wikitext = """
        ==Chinese==
        {{zh-forms|s=选择}}

        ===Verb===
        {{zh-verb}}

        # to [[choose]]; to [[select]]; to [[pick]]
        """
        let json = makeWikitextJSON(title: "選擇", wikitext: wikitext)

        let result = try DefinitionMapper.map(
            json,
            from: HTTPURLResponse(statusCode: 200),
            word: "選擇",
            language: "zh"
        )

        #expect(result.text == "選擇")
        #expect(result.language == "zh")
        #expect(result.meanings[0].partOfSpeech == "Verb")
        #expect(result.meanings[0].definition == "to choose; to select; to pick")
    }

    @Test func map_extractsExampleFromChineseTemplate() throws {
        let wikitext = """
        ==Chinese==

        ===Verb===
        {{zh-verb}}

        # to [[choose]]; to [[select]]
        #: {{zh-x|可 供 選擇|to '''choose''' from}}
        """
        let json = makeWikitextJSON(title: "選擇", wikitext: wikitext)

        let result = try DefinitionMapper.map(
            json,
            from: HTTPURLResponse(statusCode: 200),
            word: "選擇",
            language: "zh"
        )

        #expect(result.meanings[0].example == "可 供 選擇 - to choose from")
    }

    // MARK: - Spanish Word Parsing

    @Test func map_deliversSpanishWordWithEnglishDefinition() throws {
        let wikitext = """
        ==Spanish==

        ===Adjective===
        {{es-adj}}

        # [[greedy]], [[covetous]]
        """
        let json = makeWikitextJSON(title: "codicioso", wikitext: wikitext)

        let result = try DefinitionMapper.map(
            json,
            from: HTTPURLResponse(statusCode: 200),
            word: "codicioso",
            language: "es"
        )

        #expect(result.text == "codicioso")
        #expect(result.language == "es")
        #expect(result.meanings[0].definition == "greedy, covetous")
    }

    // MARK: - Phonetic Extraction

    @Test func map_extractsPhoneticFromIPATemplate() throws {
        let wikitext = """
        ==English==

        ===Pronunciation===
        * {{IPA|en|/həˈləʊ/}}

        ===Interjection===
        {{en-intj}}

        # A greeting.
        """
        let json = makeWikitextJSON(title: "hello", wikitext: wikitext)

        let result = try DefinitionMapper.map(
            json,
            from: HTTPURLResponse(statusCode: 200),
            word: "hello",
            language: "en"
        )

        #expect(result.phonetic == "/həˈləʊ/")
    }

    @Test func map_extractsPhoneticFromMultipleIPAEntries() throws {
        let wikitext = """
        ==English==

        ===Pronunciation===
        * {{a|UK}} {{IPA|en|/həˈləʊ/}}
        * {{a|US}} {{IPA|en|/həˈloʊ/}}

        ===Noun===
        # A greeting.
        """
        let json = makeWikitextJSON(title: "hello", wikitext: wikitext)

        let result = try DefinitionMapper.map(
            json,
            from: HTTPURLResponse(statusCode: 200),
            word: "hello",
            language: "en"
        )

        // Should extract the first IPA pronunciation
        #expect(result.phonetic == "/həˈləʊ/")
    }

    @Test func map_handlesWordWithoutPhonetic() throws {
        let wikitext = """
        ==English==

        ===Noun===
        # A thing.
        """
        let json = makeWikitextJSON(title: "thing", wikitext: wikitext)

        let result = try DefinitionMapper.map(
            json,
            from: HTTPURLResponse(statusCode: 200),
            word: "thing",
            language: "en"
        )

        #expect(result.phonetic == nil)
    }

    // MARK: - Edge Cases

    @Test func map_handlesDefinitionWithTemplateMarkup() throws {
        let wikitext = """
        ==English==

        ===Noun===
        {{en-noun}}

        # {{lb|en|informal}} A greeting.
        """
        let json = makeWikitextJSON(title: "hello", wikitext: wikitext)

        let result = try DefinitionMapper.map(
            json,
            from: HTTPURLResponse(statusCode: 200),
            word: "hello",
            language: "en"
        )

        // Should extract the definition, handling or stripping the template
        #expect(result.meanings[0].definition.contains("greeting") || result.meanings[0].definition.contains("A greeting"))
    }

    @Test func map_ignoresNonTargetLanguageSections() throws {
        let wikitext = """
        ==French==

        ===Noun===
        # French meaning

        ==English==

        ===Noun===
        # English meaning
        """
        let json = makeWikitextJSON(title: "test", wikitext: wikitext)

        let result = try DefinitionMapper.map(
            json,
            from: HTTPURLResponse(statusCode: 200),
            word: "test",
            language: "en"
        )

        // Should only get the English definition
        #expect(result.meanings.count == 1)
        #expect(result.meanings[0].definition == "English meaning")
    }

    // MARK: - Helpers

    private func makeWikitextJSON(title: String, wikitext: String) -> Data {
        let json: [String: Any] = [
            "parse": [
                "title": title,
                "pageid": 12345,
                "wikitext": [
                    "*": wikitext
                ]
            ]
        ]
        return try! JSONSerialization.data(withJSONObject: json)
    }

    private func makeErrorJSON(code: String, info: String) -> Data {
        let json: [String: Any] = [
            "error": [
                "code": code,
                "info": info
            ]
        ]
        return try! JSONSerialization.data(withJSONObject: json)
    }
}

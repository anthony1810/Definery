//
//  TestHelpers.swift
//  WordCacheInfrastructureTests
//
//  Created by Anthony on 2/1/26.
//

import Foundation
import WordCache

func anyNSError() -> NSError {
    NSError(domain: "any", code: 0)
}

func uniqueLocalWord() -> LocalWord {
    LocalWord(id: UUID(), text: "word-\(UUID())", language: "en", phonetic: nil, meanings: [])
}

func uniqueLocalWords() -> [LocalWord] {
    [
        LocalWord(id: UUID(), text: "hello", language: "en", phonetic: "/həˈloʊ/", meanings: [
            LocalMeaning(partOfSpeech: "noun", definition: "a greeting", example: "Hello there!")
        ]),
        LocalWord(id: UUID(), text: "world", language: "en", phonetic: "/wɜːrld/", meanings: [
            LocalMeaning(partOfSpeech: "noun", definition: "the earth", example: nil)
        ])
    ]
}

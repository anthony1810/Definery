//
//  TestHelpers.swift
//  WordCacheTests
//
//  Created by Anthony on 1/1/26.
//

import Foundation
import WordFeature
import WordCache

func anyNSError() -> NSError {
    NSError(domain: "any", code: 0)
}

func uniqueWord() -> Word {
    Word(id: UUID(), text: "word-\(UUID())", language: "en", phonetic: nil, meanings: [])
}

func uniqueLocalWord() -> LocalWord {
    LocalWord(id: UUID(), text: "word-\(UUID())", language: "en", phonetic: nil, meanings: [])
}

func uniqueWords() -> (domain: [Word], local: [LocalWord]) {
    let id1 = UUID()
    let id2 = UUID()

    let words = [
        Word(id: id1, text: "hello", language: "en", phonetic: nil, meanings: []),
        Word(id: id2, text: "world", language: "en", phonetic: nil, meanings: [])
    ]

    let localWords = [
        LocalWord(id: id1, text: "hello", language: "en", phonetic: nil, meanings: []),
        LocalWord(id: id2, text: "world", language: "en", phonetic: nil, meanings: [])
    ]

    return (words, localWords)
}

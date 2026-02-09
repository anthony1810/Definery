//
//  Meaning+Mocks.swift
//  WordFeature
//
//  Created by Anthony on 3/1/26.
//

import Foundation

public extension Meaning {
    static let mocks: [Meaning] = [
        Meaning(partOfSpeech: "noun", definition: "a feeling of deep sadness or gloom", example: "an air of melancholy surrounded him"),
        Meaning(partOfSpeech: "verb", definition: "to move swiftly and lightly", example: "she flitted from one topic to another"),
        Meaning(partOfSpeech: "adjective", definition: "lasting for a very short time", example: "fashions are ephemeral"),
        Meaning(partOfSpeech: "adverb", definition: "in a way that is open to more than one interpretation", example: "she smiled ambiguously"),
        Meaning(partOfSpeech: "noun", definition: "the occurrence of events by chance in a happy way", example: "a fortunate stroke of serendipity"),
        Meaning(partOfSpeech: "adjective", definition: "present, appearing, or found everywhere", example: "his ubiquitous influence was felt by all"),
        Meaning(partOfSpeech: "verb", definition: "to speak or write about in an abusively critical manner", example: "he was vilified in the press"),
        Meaning(partOfSpeech: "noun", definition: "the highest point reached by a celestial body", example: "the sun reaches its zenith at noon"),
        Meaning(partOfSpeech: "adjective", definition: "fluent or persuasive in speaking or writing", example: "an eloquent speech"),
        Meaning(partOfSpeech: "noun", definition: "a person or thing that is mysterious or difficult to understand", example: "she remained an enigma to him")
    ]

    static func randomMock() -> Meaning {
        mocks.randomElement() ?? mocks[0]
    }
}

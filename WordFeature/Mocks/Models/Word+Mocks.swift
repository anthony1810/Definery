//
//  Word+Mocks.swift
//  WordFeature
//
//  Created by Anthony on 3/1/26.
//

import Foundation

public extension Word {
    static let ephemeral = Word(
        id: UUID(),
        text: "ephemeral",
        language: "en",
        phonetic: "/ɪˈfem(ə)rəl/",
        meanings: [
            Meaning(partOfSpeech: "adjective", definition: "lasting for a very short time", example: "fashions are ephemeral")
        ]
    )

    static let serendipity = Word(
        id: UUID(),
        text: "serendipity",
        language: "en",
        phonetic: "/ˌserənˈdipədē/",
        meanings: [
            Meaning(partOfSpeech: "noun", definition: "the occurrence of events by chance in a happy way", example: "a fortunate stroke of serendipity")
        ]
    )

    static let ubiquitous = Word(
        id: UUID(),
        text: "ubiquitous",
        language: "en",
        phonetic: "/yo͞oˈbikwədəs/",
        meanings: [
            Meaning(partOfSpeech: "adjective", definition: "present, appearing, or found everywhere", example: "his ubiquitous influence was felt by all")
        ]
    )

    static let melancholy = Word(
        id: UUID(),
        text: "melancholy",
        language: "en",
        phonetic: "/ˈmelənˌkälē/",
        meanings: [
            Meaning(partOfSpeech: "noun", definition: "a deep sadness or gloom", example: "an air of melancholy surrounded him"),
            Meaning(partOfSpeech: "adjective", definition: "having a feeling of sadness", example: "she felt a melancholy longing")
        ]
    )

    static let eloquent = Word(
        id: UUID(),
        text: "eloquent",
        language: "en",
        phonetic: "/ˈeləkwənt/",
        meanings: [
            Meaning(partOfSpeech: "adjective", definition: "fluent or persuasive in speaking or writing", example: "an eloquent speech")
        ]
    )

    static let resilient = Word(
        id: UUID(),
        text: "resilient",
        language: "en",
        phonetic: "/rɪˈzɪliənt/",
        meanings: [
            Meaning(partOfSpeech: "adjective", definition: "able to recover quickly from difficulties", example: "she was remarkably resilient")
        ]
    )

    static let enigma = Word(
        id: UUID(),
        text: "enigma",
        language: "en",
        phonetic: "/ɪˈnɪɡmə/",
        meanings: [
            Meaning(partOfSpeech: "noun", definition: "a person or thing that is mysterious or difficult to understand", example: "she remained an enigma to him")
        ]
    )

    static let zenith = Word(
        id: UUID(),
        text: "zenith",
        language: "en",
        phonetic: "/ˈzēnəTH/",
        meanings: [
            Meaning(partOfSpeech: "noun", definition: "the highest point reached by a celestial body", example: "the sun reaches its zenith at noon")
        ]
    )

    static let ethereal = Word(
        id: UUID(),
        text: "ethereal",
        language: "en",
        phonetic: "/ɪˈTHirēəl/",
        meanings: [
            Meaning(partOfSpeech: "adjective", definition: "extremely delicate and light in a way that seems not of this world", example: "her ethereal beauty")
        ]
    )

    static let quintessential = Word(
        id: UUID(),
        text: "quintessential",
        language: "en",
        phonetic: "/ˌkwintəˈsen(t)SHəl/",
        meanings: [
            Meaning(partOfSpeech: "adjective", definition: "representing the most perfect example of a quality", example: "he was the quintessential gentleman")
        ]
    )

    static let luminous = Word(
        id: UUID(),
        text: "luminous",
        language: "en",
        phonetic: "/ˈlo͞omənəs/",
        meanings: [
            Meaning(partOfSpeech: "adjective", definition: "full of or shedding light; bright", example: "the luminous glow of the moon")
        ]
    )

    static let whimsical = Word(
        id: UUID(),
        text: "whimsical",
        language: "en",
        phonetic: "/ˈ(h)wimzikəl/",
        meanings: [
            Meaning(partOfSpeech: "adjective", definition: "playfully quaint or fanciful", example: "a whimsical sense of humor")
        ]
    )

    static let ineffable = Word(
        id: UUID(),
        text: "ineffable",
        language: "en",
        phonetic: "/inˈefəb(ə)l/",
        meanings: [
            Meaning(partOfSpeech: "adjective", definition: "too great or extreme to be expressed in words", example: "the ineffable beauty of the scene")
        ]
    )

    static let sonder = Word(
        id: UUID(),
        text: "sonder",
        language: "en",
        phonetic: "/ˈsändər/",
        meanings: [
            Meaning(partOfSpeech: "noun", definition: "the realization that each passerby has a life as vivid as your own", example: "he experienced a moment of sonder")
        ]
    )

    static let petrichor = Word(
        id: UUID(),
        text: "petrichor",
        language: "en",
        phonetic: "/ˈpetrīˌkôr/",
        meanings: [
            Meaning(partOfSpeech: "noun", definition: "a pleasant smell after rain falls on dry ground", example: "the petrichor filled the air")
        ]
    )

    static let vellichor = Word(
        id: UUID(),
        text: "vellichor",
        language: "en",
        phonetic: "/ˈveliˌkôr/",
        meanings: [
            Meaning(partOfSpeech: "noun", definition: "the strange wistfulness of used bookstores", example: "she felt a sense of vellichor among the old books")
        ]
    )

    static let hiraeth = Word(
        id: UUID(),
        text: "hiraeth",
        language: "en",
        phonetic: "/ˈhirˌīTH/",
        meanings: [
            Meaning(partOfSpeech: "noun", definition: "a homesickness for a home you cannot return to", example: "he felt hiraeth for his childhood")
        ]
    )

    static let apricity = Word(
        id: UUID(),
        text: "apricity",
        language: "en",
        phonetic: "/əˈprisədē/",
        meanings: [
            Meaning(partOfSpeech: "noun", definition: "the warmth of the sun in winter", example: "she basked in the apricity of the February afternoon")
        ]
    )

    static let numinous = Word(
        id: UUID(),
        text: "numinous",
        language: "en",
        phonetic: "/ˈn(y)o͞omənəs/",
        meanings: [
            Meaning(partOfSpeech: "adjective", definition: "having a strong religious or spiritual quality", example: "the numinous presence in the ancient temple")
        ]
    )

    static let susurrus = Word(
        id: UUID(),
        text: "susurrus",
        language: "en",
        phonetic: "/so͞oˈsərəs/",
        meanings: [
            Meaning(partOfSpeech: "noun", definition: "a whispering or rustling sound", example: "the susurrus of the wind through the leaves")
        ]
    )

    static let mocks: [Word] = [
        .ephemeral, .serendipity, .ubiquitous, .melancholy,
        .eloquent, .resilient, .enigma, .zenith,
        .ethereal, .quintessential, .luminous, .whimsical,
        .ineffable, .sonder, .petrichor, .vellichor,
        .hiraeth, .apricity, .numinous, .susurrus
    ]

    static func randomMocks(count: Int) -> [Word] {
        Array(mocks.shuffled().prefix(count))
    }
}

extension Word: Identifiable {}

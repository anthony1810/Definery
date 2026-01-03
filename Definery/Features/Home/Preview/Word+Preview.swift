//
//  Word+Preview.swift
//  Definery
//
//  Created by Anthony on 3/1/26.
//

import Foundation
import WordFeature

#if DEBUG
extension Word {
    static let ephemeral = Word(
        id: UUID(),
        text: "ephemeral",
        language: "en",
        phonetic: "/ɪˈfem(ə)rəl/",
        meanings: [
            Meaning(
                partOfSpeech: "adjective",
                definition: "lasting for a very short time",
                example: "fashions are ephemeral"
            )
        ]
    )

    static let serendipity = Word(
        id: UUID(),
        text: "serendipity",
        language: "en",
        phonetic: "/ˌserənˈdipədē/",
        meanings: [
            Meaning(
                partOfSpeech: "noun",
                definition: "the occurrence of events by chance in a happy way",
                example: "a fortunate stroke of serendipity"
            )
        ]
    )

    static let ubiquitous = Word(
        id: UUID(),
        text: "ubiquitous",
        language: "en",
        phonetic: "/yo͞oˈbikwədəs/",
        meanings: [
            Meaning(
                partOfSpeech: "adjective",
                definition: "present, appearing, or found everywhere",
                example: "his ubiquitous influence was felt by all"
            )
        ]
    )

    static let melancholy = Word(
        id: UUID(),
        text: "melancholy",
        language: "en",
        phonetic: "/ˈmelənˌkälē/",
        meanings: [
            Meaning(
                partOfSpeech: "noun",
                definition: "a deep sadness or gloom",
                example: "an air of melancholy surrounded him"
            ),
            Meaning(
                partOfSpeech: "adjective",
                definition: "having a feeling of sadness",
                example: "she felt a melancholy longing"
            )
        ]
    )

    static let samples: [Word] = [
        .ephemeral,
        .serendipity,
        .ubiquitous,
        .melancholy
    ]
}

extension Word: Identifiable {}
#endif

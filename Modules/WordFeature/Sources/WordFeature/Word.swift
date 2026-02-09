//
//  Word.swift
//  WordFeature
//
//  Created by Anthony on 31/12/25.
//

import Foundation

public struct Word: Equatable, Hashable, Sendable {
    public let id: UUID
    public let text: String
    public let language: String
    public let phonetic: String?
    public let meanings: [Meaning]

    public init(id: UUID, text: String, language: String, phonetic: String?, meanings: [Meaning]) {
        self.id = id
        self.text = text
        self.language = language
        self.phonetic = phonetic
        self.meanings = meanings
    }
}

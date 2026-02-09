//
//  LocalWord.swift
//  WordCache
//
//  Created by Anthony on 2/1/26.
//

import Foundation

public struct LocalWord: Equatable, Sendable {
    public let id: UUID
    public let text: String
    public let language: String
    public let phonetic: String?
    public let meanings: [LocalMeaning]

    public init(id: UUID, text: String, language: String, phonetic: String?, meanings: [LocalMeaning]) {
        self.id = id
        self.text = text
        self.language = language
        self.phonetic = phonetic
        self.meanings = meanings
    }
}

//
//  LocalMeaning.swift
//  WordCache
//
//  Created by Anthony on 2/1/26.
//

import Foundation

public struct LocalMeaning: Equatable, Sendable {
    public let partOfSpeech: String
    public let definition: String
    public let example: String?

    public init(partOfSpeech: String, definition: String, example: String?) {
        self.partOfSpeech = partOfSpeech
        self.definition = definition
        self.example = example
    }
}

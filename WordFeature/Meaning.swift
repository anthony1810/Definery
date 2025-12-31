//
//  Meaning.swift
//  WordFeature
//
//  Created by Anthony on 31/12/25.
//

public struct Meaning: Equatable, Hashable, Sendable {
    public let partOfSpeech: String
    public let definition: String
    public let example: String?

    public init(partOfSpeech: String, definition: String, example: String?) {
        self.partOfSpeech = partOfSpeech
        self.definition = definition
        self.example = example
    }
}

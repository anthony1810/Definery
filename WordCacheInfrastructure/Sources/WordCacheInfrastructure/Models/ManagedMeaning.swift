//
//  ManagedMeaning.swift
//  Definery
//
//  Created by Anthony on 2/1/26.
//

import Foundation
import SwiftData

import WordCache

@Model
final class ManagedMeaning {
    var partOfSpeech: String
    var definition: String
    var example: String?
    
    init(partOfSpeech: String, definition: String, example: String? = nil) {
        self.partOfSpeech = partOfSpeech
        self.definition = definition
        self.example = example
    }
}

extension ManagedMeaning {
    convenience init(from local: LocalMeaning) {
        self.init(
            partOfSpeech: local.partOfSpeech,
            definition: local.definition,
            example: local.example
        )
    }

    func toLocal() -> LocalMeaning {
        LocalMeaning(
            partOfSpeech: partOfSpeech,
            definition: definition,
            example: example
        )
    }
}

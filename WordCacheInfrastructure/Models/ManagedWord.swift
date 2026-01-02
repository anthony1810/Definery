//
//  ManagedWord.swift
//  Definery
//
//  Created by Anthony on 2/1/26.
//

import Foundation
import SwiftData

import WordCache

@Model
final class ManagedWord {
    @Attribute(.unique) var id: UUID
    var text: String
    var language: String
    var phonetic: String?
    
    @Relationship(deleteRule: .cascade) var meanings: [ManagedMeaning]
        
    init(
        id: UUID,
        text: String,
        language: String,
        phonetic: String? = nil,
        meanings: [ManagedMeaning]
    ) {
        self.id = id
        self.text = text
        self.language = language
        self.phonetic = phonetic
        self.meanings = meanings
    }
}

extension ManagedWord {
    convenience init(from local: LocalWord) {
        self.init(
            id: local.id,
            text: local.text,
            language: local.language,
            phonetic: local.phonetic,
            meanings: local.meanings.map { ManagedMeaning(from: $0) }
        )
    }
    
    func toLocal() -> LocalWord {
        LocalWord(
            id: id,
            text: text,
            language: language,
            phonetic: phonetic,
            meanings: meanings.map { $0.toLocal() }
        )
    }
}

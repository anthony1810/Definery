//
//  TestHelpers.swift
//  DefineryTests
//
//  Created by Anthony on 2/1/26.
//

import Foundation
import WordFeature

func uniqueWord() -> Word {
    Word(id: UUID(), text: "word-\(UUID())", language: "en", phonetic: nil, meanings: [])
}

func anyNSError() -> NSError {
    NSError(domain: "any", code: 0)
}

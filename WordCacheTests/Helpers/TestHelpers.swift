//
//  TestHelpers.swift
//  WordCacheTests
//
//  Created by Anthony on 1/1/26.
//

import Foundation
import WordFeature

func anyNSError() -> NSError {
    NSError(domain: "any", code: 0)
}

func uniqueWord() -> Word {
    Word(id: UUID(), text: "word-\(UUID())", language: "en", phonetic: nil, meanings: [])
}

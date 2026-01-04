//
//  SharedTestHelpers.swift
//  WordAPITests
//
//  Created by Anthony on 1/1/26.
//

import Foundation

func anyURL() -> URL {
    URL(string: "https://any-url.com")!
}

func anyNSError() -> NSError {
    NSError(domain: "any", code: 0)
}

func anyData() -> Data {
    Data("any data".utf8)
}

func makeWordsJSON(_ words: [String]) -> Data {
    try! JSONSerialization.data(withJSONObject: words)
}

func anyLanguageCode() -> String {
    "en"
}

// MARK: - HTTPURLResponse Extension

extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: URL(string: "https://any-url.com")!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}

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

//
//  RandomWordMapperTests.swift
//  WordAPITests
//
//  Created by Anthony on 4/1/26.
//

import Testing
import Foundation
@testable import WordAPI

struct RandomWordMapperTests {
    
    @Test func map_throwsErrorOnNon200HTTPResponse() throws {
        let samples = [199, 201, 300, 400, 500]
        
        for statusCode in samples {
            #expect(throws: RandomWordMapper.Error.invalidData) {
                try RandomWordMapper.map(anyData(), from: HTTPURLResponse(statusCode: statusCode))
            }
        }
    }
    
    @Test func map_throwsErrorOn200HTTPResponseWithInvalidJSON() throws {
        let invalidJSONData = "invalid json".data(using: .utf8)!
        
        #expect(throws: RandomWordMapper.Error.invalidData) {
            try RandomWordMapper.map(invalidJSONData, from: HTTPURLResponse(statusCode: 200))
        }
    }
    
    @Test func map_deliversEmptyArrayOn200HTTPResponseWithEmptyArray() throws {
        let emptyListJSON = makeWordsJSON([])
        
        let result = try RandomWordMapper.map(emptyListJSON, from: HTTPURLResponse(statusCode: 200))
        
        #expect(result == [])
    }
    
    @Test func map_deliversWordsOn200HTTPResponseWithValidArray() throws {
        let words = ["alpha", "bravo", "charlie"]
        let wordsJSON = makeWordsJSON(words)
        
        let result = try RandomWordMapper.map(wordsJSON, from: HTTPURLResponse(statusCode: 200))
        
        #expect(result == words)
    }
}

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
}

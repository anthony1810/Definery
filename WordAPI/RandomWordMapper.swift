//
//  RandomWordMapper.swift
//  WordAPI
//
//  Created by Anthony on 4/1/26.
//

import Foundation

public enum RandomWordMapper {
    public enum Error: Swift.Error {
        case invalidData
    }

    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> [String] {
        guard response.isOK,
              let words = try? JSONDecoder().decode([String].self, from: data)
        else {
            throw Error.invalidData
        }
        
        return words
    }
}

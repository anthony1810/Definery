//
//  WordMapper.swift
//  WordAPI
//
//  Created by Anthony on 31/12/25.
//

import Foundation
import WordFeature

public enum WordMapper {
    public enum Error: Swift.Error {
        case invalidData
    }

    private struct Root: Decodable {
        let items: [RemoteWord]

        var words: [Word] {
            items.map { $0.toModel() }
        }
    }

    private struct RemoteWord: Decodable {
        let id: UUID
        let text: String
        let language: String
        let phonetic: String?
        let meanings: [RemoteMeaning]

        func toModel() -> Word {
            Word(
                id: id,
                text: text,
                language: language,
                phonetic: phonetic,
                meanings: meanings.map { $0.toModel() }
            )
        }
    }

    private struct RemoteMeaning: Decodable {
        let partOfSpeech: String
        let definition: String
        let example: String?

        func toModel() -> Meaning {
            Meaning(
                partOfSpeech: partOfSpeech,
                definition: definition,
                example: example
            )
        }
    }

    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> [Word] {
        guard response.isOK,
              let root = try? JSONDecoder().decode(Root.self, from: data)
        else {
            throw WordMapper.Error.invalidData
        }

        return root.words
    }
}

extension HTTPURLResponse {
    var isOK: Bool {
        statusCode == 200
    }
}

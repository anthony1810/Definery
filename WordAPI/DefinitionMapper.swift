//
//  DefinitionMapper.swift
//  WordAPI
//
//  Created by Anthony on 4/1/26.
//

import Foundation
import WordFeature

public enum DefinitionMapper {
    public enum Error: Swift.Error {
        case invalidData
    }
    
    private struct RemoteWordEntry: Decodable {
        let word: String
        let phonetic: String?
        let meanings: [RemoteMeaning]
    }
    
    private struct RemoteMeaning: Decodable {
        let partOfSpeech: String
        let definitions: [RemoteDefinition]
    }
    
    private struct RemoteDefinition: Decodable {
        let definition: String
        let example: String?
    }

    public static func map(_ data: Data, from response: HTTPURLResponse, language: String) throws -> Word {
        guard response.isOK,
              let entries = try? JSONDecoder().decode([RemoteWordEntry].self, from: data),
              let first = entries.first
        else {
            throw Error.invalidData
        }

        return Word(
            id: UUID(),
            text: first.word,
            language: language,
            phonetic: first.phonetic,
            meanings: first.meanings.compactMap { meaning in
                guard let def = meaning.definitions.first else { return nil }
                return Meaning(
                    partOfSpeech: meaning.partOfSpeech,
                    definition: def.definition,
                    example: def.example
                )
            }
        )
    }
}

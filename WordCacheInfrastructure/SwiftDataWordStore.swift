//
//  SwiftDataWordStore.swift
//  Definery
//
//  Created by Anthony on 2/1/26.
//
import Foundation
import SwiftData
import WordCache

public final class SwiftDataWordStore: WordStorageProtocol, @unchecked Sendable {
    private let container: ModelContainer
    private let context: ModelContext

    public init(inMemory: Bool = false) throws {
        let schema = Schema([ManagedWord.self, ManagedMeaning.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: inMemory)

        container = try ModelContainer(for: schema, configurations: config)
        context = ModelContext(container)
    }

    public func deleteCachedWords() async throws {}

    public func insertCache(words: [LocalWord]) async throws {
        for word in words {
            let managed = ManagedWord(from: word)
            context.insert(managed)
        }
        try context.save()
    }

    public func retrieveWords() async throws -> [LocalWord] {
        let descriptor = FetchDescriptor<ManagedWord>()
        let managedWords = try context.fetch(descriptor)
        return managedWords.map { $0.toLocal() }
    }
}

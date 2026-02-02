//
//  SwiftDataWordStore.swift
//  Definery
//
//  Created by Anthony on 2/1/26.
//
import Foundation
import SwiftData
import WordCache

@ModelActor
public actor SwiftDataWordStore: WordStorageProtocol {

    public init(inMemory: Bool = false) throws {
        let schema = Schema([ManagedWord.self, ManagedMeaning.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: inMemory)
        let container = try ModelContainer(for: schema, configurations: config)

        self.init(modelContainer: container)
    }

    public func deleteCachedWords() throws {
        try modelContext.delete(model: ManagedWord.self)
        try modelContext.save()
    }

    public func insertCache(words: [LocalWord]) throws {
        try modelContext.delete(model: ManagedWord.self)

        words
            .map(ManagedWord.init)
            .forEach(modelContext.insert)

        try modelContext.save()
    }

    public func retrieveWords() throws -> [LocalWord] {
        let descriptor = FetchDescriptor<ManagedWord>()
        let managedWords = try modelContext.fetch(descriptor)
        return managedWords.map { $0.toLocal() }
    }
}

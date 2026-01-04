//
//  DefineryApp.swift
//  Definery
//
//  Created by Anthony on 31/12/25.
//

import SwiftUI
import Foundation
import WordFeature
import WordAPI
import WordCache
import WordCacheInfrastructure

@main
struct DefineryApp: App {
    private let httpClient: HTTPClient = URLSessionHTTPClient()
    private let store: WordStorageProtocol = try! SwiftDataWordStore()
    
    var body: some Scene {
        WindowGroup {
            HomeUIComposer.homeComposedWith(loader: makeLoader())
        }
    }
}

extension DefineryApp {
    nonisolated func makeLoader() -> WordLoaderFactory {
        let httpClient = self.httpClient
        let store = self.store
        let randomWordsBaseURL = URL(string: "https://random-word-api.herokuapp.com")!
        let definitionBaseURL = URL(string: "https://en.wiktionary.org")!

        return { language in
            // Random Word API uses "pt-br" for Portuguese, not "pt"
            let apiLanguage = language == .portuguese ? "pt-br" : language.identifier

            let randomWordsURL = WordsEndpoint.randomWords(
                count: 10,
                language: apiLanguage
            ).url(baseURL: randomWordsBaseURL)

            let remote = RemoteWordLoader(
                client: httpClient,
                randomWordsURL: randomWordsURL,
                definitionURLBuilder: { word in
                    WordsEndpoint.definition(word: word, language: language.identifier)
                        .url(baseURL: definitionBaseURL)
                },
                language: language.identifier
            )
            let local = LocalWordLoader(store: store)

            return RemoteWithLocalFallbackLoader(remote: remote, local: local, cache: local)
        }
    }
}

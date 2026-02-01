//
//  HomeViewState.swift
//  Definery
//
//  Created by Anthony on 3/1/26.
//
import SwiftUI
import Observation

import WordFeature
import ScreenStateKit

@MainActor @Observable
final class HomeViewState: LoadmoreScreenState, StateUpdatable {
    var words: [Word] = []
    var selectedLanguage: Locale.LanguageCode = .english
    var errorMessage: String?

    var hasWords: Bool { !words.isEmpty }
    var hasError: Bool { errorMessage != nil }
}

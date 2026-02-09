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
    var snapshot: HomeSnapshot = .placeholder

    var hasWords: Bool { snapshot.hasWords }
    var hasError: Bool { displayError?.errorDescription != nil }
}

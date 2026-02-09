//
//  HomeUIComposer.swift
//  Definery
//
//  Created by Anthony on 3/1/26.
//

import SwiftUI
import WordFeature

@MainActor
enum HomeUIComposer {
    static func homeComposedWith(
        loader: @escaping WordLoaderFactory
    ) -> HomeView {
        let viewState = HomeViewState()
        let viewStore = HomeViewStore(loader: loader)
        
        return HomeView(viewStore: viewStore, viewState: viewState)
    }
}

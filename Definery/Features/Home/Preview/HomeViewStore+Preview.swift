//
//  HomeViewStore+Preview.swift
//  Definery
//
//  Created by Anthony on 3/1/26.
//

import Foundation
import WordFeature

#if DEBUG
extension HomeViewStore {
    /// Default preview with mock data
    static var preview: HomeViewStore {
        HomeViewStore(loader: { _ in
            MockWordLoader()
        })
    }

    /// Preview that returns empty words
    static var previewEmpty: HomeViewStore {
        HomeViewStore(loader: { _ in
            MockWordLoader(wordsPerLoad: 0)
        })
    }

    /// Preview that simulates slow loading
    static var previewLoading: HomeViewStore {
        HomeViewStore(loader: { _ in
            MockWordLoader(delay: .seconds(60))
        })
    }

    /// Preview that fails with error
    static var previewError: HomeViewStore {
        HomeViewStore(loader: { _ in
            MockWordLoader(shouldFail: true)
        })
    }
}
#endif

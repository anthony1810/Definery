//
//  HomeView.swift
//  Definery
//
//  Created by Anthony on 3/1/26.
//

import SwiftUI
import ScreenStateKit
import WordFeature

struct HomeView: View {
    @State private var viewState = HomeViewState()
    @State private var viewStore: HomeViewStore

    init(viewStore: HomeViewStore) {
        self._viewStore = State(initialValue: viewStore)
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Definery")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        LanguagePickerView(
                            selected: viewState.selectedLanguage,
                            onSelect: { language in
                                viewStore.receive(action: .selectLanguage(language))
                            }
                        )
                    }
                }
        }
        .onShowLoading($viewState.isLoading)
        .onShowError($viewState.displayError)
        .task {
            await viewStore.binding(state: viewState)
            viewStore.receive(action: .loadWords)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewState.loadState {
        case .idle:
            EmptyView()
        case .loaded(let words) where words.isEmpty:
            emptyState
        case .loaded:
            wordList
        case .error(let errorMessage):
            errorState(errorMessage)
        }
    }

    private var wordList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewState.words) { word in
                    WordCardView(word: word)
                        .onAppear {
                            loadMoreIfNeeded(for: word)
                        }
                }
            }
            .padding()
        }
        .refreshable {
            await refresh()
        }
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "No Words",
            systemImage: "book.closed",
            description: Text("Pull to refresh or try a different language")
        )
    }

    private func errorState(_ message: String) -> some View {
        ContentUnavailableView {
            Label("Something Went Wrong", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("Try Again") {
                viewStore.receive(action: .loadWords)
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private func loadMoreIfNeeded(for word: Word) {
        guard word.id == viewState.words.last?.id else { return }
        viewStore.receive(action: .loadMore)
    }

    @MainActor
    private func refresh() async {
        viewStore.receive(action: .loadWords)
        try? await Task.sleep(for: .milliseconds(500))
    }
}

// MARK: - Preview

#if DEBUG
#Preview("With Words") {
    HomeView(viewStore: .preview)
}

#Preview("Empty State") {
    HomeView(viewStore: .previewEmpty)
}

#Preview("Loading") {
    HomeView(viewStore: .previewLoading)
}

#Preview("Error") {
    HomeView(viewStore: .previewError)
}
#endif

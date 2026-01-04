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
    @State private var viewState: HomeViewState
    @State private var viewStore: HomeViewStore

    init(viewStore: HomeViewStore, viewState: HomeViewState) {
        self._viewStore = State(initialValue: viewStore)
        self._viewState = State(initialValue: viewState)
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(String(localized: "navigation.title", table: "Home"))
                .toolbar { toolbarContent }
        }
        .onShowLoading($viewState.isLoading)
        .onShowError($viewState.displayError)
        .task {
            await viewStore.binding(state: viewState)
            viewStore.receive(action: .loadWords)
        }
    }
}

// MARK: - Toolbar

extension HomeView {
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
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

// MARK: - Components

extension HomeView {
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
        List {
            ForEach(viewState.words) { word in
                WordCardView(word: word)
                    .listRowSeparator(.hidden)
            }

            if viewState.isLoadingMore {
                ProgressView()
                    .id(UUID())
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
            } else {
                Color.clear
                    .frame(height: 1)
                    .listRowSeparator(.hidden)
                    .onAppear {
                        viewStore.receive(action: .loadMore)
                    }
            }
        }
        .listStyle(.plain)
        .refreshable {
            try? await viewStore.isolatedReceive(action: .loadWords)
        }
    }

    private var emptyState: some View {
        ContentUnavailableView(
            String(localized: "empty.title", table: "Home"),
            systemImage: "book.closed",
            description: Text("empty.description", tableName: "Home")
        )
    }

    private func errorState(_ message: String) -> some View {
        ContentUnavailableView {
            Label(String(localized: "error.title", table: "Home"), systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button(String(localized: "error.tryAgain", table: "Home")) {
                viewStore.receive(action: .loadWords)
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview("With Words") {
    HomeView(viewStore: .preview, viewState: HomeViewState())
}

#Preview("Empty State") {
    HomeView(viewStore: .previewEmpty, viewState: HomeViewState())
}

#Preview("Loading") {
    HomeView(viewStore: .previewLoading, viewState: HomeViewState())
}

#Preview("Error") {
    HomeView(viewStore: .previewError, viewState: HomeViewState())
}
#endif

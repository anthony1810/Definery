# Definery

One of the most important aspects of learning a new language is vocabulary, but remembering new words is simple yet very difficult to maintain. **Definery** is your custom dictionary on your journey of learning a new language — it remembers new words for you and helps you maintain those words in your memory.

> This project also serves as a real-world demo for [ScreenStateKit](https://github.com/anthony1810/ScreenStateKit), showcasing the Three Pillars pattern (State + ViewModel + View) in a production-like iOS app with clean architecture and offline-first capability.

## Build Status

| Workflow | Status |
|----------|--------|
| Release to Testflight | ![Release Status](https://github.com/anthony1810/Definery/actions/workflows/xcc-release.yml/badge.svg) |
| Test Runner iOS | ![iOS Tests](https://github.com/anthony1810/Definery/actions/workflows/xcc-test-ios.yml/badge.svg) |
| Test Runner macOS | ![macOS Tests](https://github.com/anthony1810/Definery/actions/workflows/xcc-test-macos.yml/badge.svg) |

## Features

### Home Screen
- [ ] Browse random words with pull-to-refresh
- [ ] Load more pagination
- [ ] Language filter (English, Spanish, French, etc.)
- [ ] Save words to library
- [ ] Offline fallback to cached words

### Library Screen
- [ ] View saved words
- [ ] Delete words from library
- [ ] View word details

### Quiz Mode
- [ ] Countdown timer challenge
- [ ] Pick the correct meaning from multiple choices
- [ ] Words sourced from user's library
- [ ] Score tracking

---

## Architecture Overview

This project follows **Clean Architecture** principles with separate frameworks for each layer.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              MAIN APP                                        │
│                          (Definery target)                                   │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                      Composition Root                                │    │
│  │  - Wires all dependencies                                            │    │
│  │  - Creates RemoteWithLocalFallback loader                            │    │
│  │  - Injects into ViewStores                                           │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                         UI Layer                                     │    │
│  │  - SwiftUI Views (HomeView, LibraryView, QuizView)                  │    │
│  │  - ViewStates (ScreenState subclasses)                               │    │
│  │  - ViewStores (ScreenActionStore actors)                             │    │
│  │  - Uses ScreenStateKit patterns                                      │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────┘
          │                         │                         │
          ▼                         ▼                         ▼
┌──────────────────┐    ┌──────────────────┐    ┌──────────────────────────┐
│   WordFeature    │    │     WordAPI      │    │       WordCache          │
│   (Framework)    │    │   (Framework)    │    │      (Framework)         │
├──────────────────┤    ├──────────────────┤    ├──────────────────────────┤
│ • Word (Model)   │◄───│ • RemoteLoader   │    │ • LocalWordLoader        │
│ • Meaning        │    │ • WordMapper     │    │ • WordStorageProtocol    │
│ • WordLoader     │◄───│ • WordsEndpoint  │    │ • LocalWord (DTO)        │
│   (Protocol)     │    │                  │    │ • LocalMeaning (DTO)     │
│                  │    │ Depends on:      │    │                          │
│                  │    │ → WordFeature    │    │ Depends on:              │
│                  │    │                  │    │ → WordFeature            │
└──────────────────┘    └──────────────────┘    └──────────────────────────┘
                                                            │
                                                            ▼
                                              ┌──────────────────────────┐
                                              │ WordCacheInfrastructure  │
                                              │      (Framework)         │
                                              ├──────────────────────────┤
                                              │ • SwiftDataWordStore     │
                                              │ • InMemoryWordStore      │
                                              │                          │
                                              │ Depends on:              │
                                              │ → WordCache              │
                                              └──────────────────────────┘
```

---

## Data Flow

### Remote with Local Fallback Pattern

```
User triggers refresh/load
         │
         ▼
┌─────────────────────┐
│  RemoteWordLoader   │ ──────► Fetch from API
└─────────────────────┘
         │
         ├── [Success] ──► Cache to LocalWordLoader ──► Return [Word]
         │
         └── [Failure] ──► Fallback to LocalWordLoader.load() ──► Return cached [Word]
```

### APIs Used

| Purpose | API | Endpoint |
|---------|-----|----------|
| Random Words | [random-word-api](https://random-word-api.herokuapp.com) | `GET /word?number=20&lang=en` |
| Definitions | [Wiktionary API](https://en.wiktionary.org) | `GET /w/api.php?action=parse&format=json&page={word}&prop=wikitext` |

**Note:** Wiktionary provides English definitions for words in all supported languages (en, es, it, de, fr, zh, pt-br).

---

## Project Structure

```
Definery/
├── README.md
├── Definery.xcodeproj/
│
├── WordFeature/                      # Domain Layer (Framework, no tests)
│   ├── Word.swift                    # Domain model
│   ├── Meaning.swift                 # Value object for word meanings
│   ├── WordLoaderProtocol.swift      # Protocol for loading words
│   └── WordCacheProtocol.swift       # Protocol for caching words
│
├── WordAPI/                          # API Layer (Framework)
│   ├── Shared/
│   │   ├── HTTPClientProtocol.swift  # HTTP client abstraction
│   │   └── URLSessionHTTPClient.swift # URLSession implementation
│   ├── RemoteWordLoader.swift        # Composite loader (random words + definitions)
│   ├── WordsEndpoint.swift           # URL builder for APIs
│   ├── RandomWordMapper.swift        # Maps Random Word API JSON → [String]
│   ├── DefinitionMapper.swift        # Maps Wiktionary API wikitext → Word
│   └── WordMapper.swift              # Legacy mapper (deprecated)
│
├── WordAPITests/                     # API tests
│   ├── RemoteWordLoaderTests.swift
│   ├── RandomWordMapperTests.swift
│   ├── DefinitionMapperTests.swift
│   ├── WordMapperTests.swift
│   ├── WordsEndpointTests.swift
│   └── WordAPIEndToEndTests.swift
│
├── WordCache/                        # Cache Layer (Framework)
│   ├── LocalWordLoader.swift         # Cache use case (implements WordCacheProtocol)
│   ├── WordStorageProtocol.swift     # Protocol for store implementations
│   └── Models/
│       ├── LocalWord.swift           # Cache DTO for Word
│       └── LocalMeaning.swift        # Cache DTO for Meaning
│
├── WordCacheTests/                   # Cache tests
│   ├── CacheWordUseCaseTests.swift   # Save tests
│   ├── LoadWordFromCacheUseCaseTests.swift  # Load tests
│   └── Helpers/
│       ├── WordStorageSpy.swift      # Test double
│       ├── TestHelpers.swift         # Test utilities
│       └── Optional+Evaluate.swift   # Result evaluation
│
├── WordCacheInfrastructure/          # Infrastructure Layer (Framework)
│   ├── SwiftDataWordStore.swift      # SwiftData implementation
│   └── InMemoryWordStore.swift       # In-memory implementation (testing)
│
├── WordCacheInfrastructureTests/     # Infrastructure tests
│   └── SwiftDataWordStoreTests.swift
│
├── DefineryTests/                    # Main App Tests
│   ├── HomeViewStoreTests.swift
│   ├── HomeViewSnapshotTests.swift
│   ├── RemoteWithLocalFallbackLoaderTests.swift
│   └── Helpers/
│       ├── MemoryLeakTracker.swift
│       ├── WordLoaderSpy.swift
│       ├── WordCacheSpy.swift
│       └── TestHelpers.swift
│
└── Definery/                         # Main App Target
    ├── DefineryApp.swift             # App entry point
    ├── AppError.swift                # App-level error handling
    ├── Composer/
    │   ├── HomeUIComposer.swift      # Wires HomeView dependencies
    │   └── RemoteWithLocalFallbackLoader.swift  # Remote + local fallback
    └── Features/
        └── Home/
            ├── HomeViewState.swift   # ScreenState subclass
            ├── HomeViewStore.swift   # ScreenActionStore actor
            ├── HomeView.swift        # SwiftUI view
            ├── Preview/
            │   └── HomeViewStore+Preview.swift
            └── Views/
                ├── LanguagePickerView.swift
                └── WordCardView.swift
```

---

## Framework Dependencies

```
WordFeature (no dependencies)
     ▲
     │
     ├──────────────┬──────────────────┐
     │              │                  │
 WordAPI      WordCache          Main App
     │              │                  │
     │              ▼                  │
     │    WordCacheInfrastructure      │
     │              │                  │
     └──────────────┴──────────────────┘
                    │
                    ▼
              ScreenStateKit
```

---

## Domain Models

### Word (Domain Model)

```swift
public struct Word: Equatable, Hashable {
    public let id: UUID
    public let text: String
    public let language: String
    public let phonetic: String?
    public let meanings: [Meaning]
}
```

### Meaning (Value Object)

```swift
public struct Meaning: Equatable, Hashable {
    public let partOfSpeech: String
    public let definition: String
    public let example: String?
}
```

---

## Protocols

### WordLoaderProtocol

```swift
public protocol WordLoaderProtocol {
    func load() async throws -> [Word]
}
```

### WordCacheProtocol (Domain Layer)

```swift
public protocol WordCacheProtocol: Sendable {
    func save(_ words: [Word]) async throws
}
```

**Implemented by:** `LocalWordLoader` in WordCache framework

### WordStorageProtocol (Cache Layer)

```swift
public protocol WordStorageProtocol: Sendable {
    func deleteCachedWords() async throws
    func insertCache(words: [LocalWord]) async throws
    func retrieveWords() async throws -> [LocalWord]
}
```

### LocalWord (Cache DTO)

```swift
public struct LocalWord: Equatable {
    public let id: UUID
    public let text: String
    public let language: String
    public let phonetic: String?
    public let meanings: [LocalMeaning]
}
```

**Purpose:** Cache DTOs (`LocalWord`, `LocalMeaning`) create a protocol boundary between the cache layer and infrastructure layer, allowing SwiftData models to be independent of domain models.

---

## ScreenStateKit Integration

Each feature follows the **Three Pillars** pattern from [ScreenStateKit](https://github.com/anthony1810/ScreenStateKit):

### 1. State (ScreenState subclass)

```swift
@Observable @MainActor
final class HomeViewState: ScreenState {
    private(set) var words: [Word] = []
    private(set) var selectedLanguage: Language = .english
    private(set) var canLoadMore: Bool = true
}
```

### 2. ViewStore (ScreenActionStore actor)

```swift
actor HomeViewStore: ScreenActionStore {
    enum Action: ActionLockable, LoadingTrackable, Sendable {
        case refresh
        case loadMore
        case saveWord(Word)
    }

    func binding(state: HomeViewState) { ... }
    nonisolated func receive(action: Action) { ... }
}
```

### 3. View (SwiftUI)

```swift
struct HomeView: View {
    @State private var viewState: HomeViewState
    @State private var viewStore: HomeViewStore

    var body: some View {
        // ...
        .onShowLoading($viewState.isLoading)
        .onShowError($viewState.displayError)
        .task {
            await viewStore.binding(state: viewState)
            viewStore.receive(action: .refresh)
        }
    }
}
```

---

## Implementation Progress

### Phase 1: Domain Layer
- [x] Create WordFeature framework
- [x] Create WordLoaderProtocol
- [x] Define Word model with properties
- [x] Define Meaning model
- [x] Add Equatable/Hashable/Sendable conformance

### Phase 2: API Layer
- [x] Create WordAPI framework
- [x] Create HTTPClient protocol and URLSessionHTTPClient
- [x] Create RemoteWordLoader
- [x] Create WordsEndpoint (URL builder)
- [x] Create WordMapper (JSON → Word)
- [x] Write RemoteWordLoaderTests
- [x] Write WordMapperTests
- [x] Write WordsEndpointTests

### Phase 3: Cache Layer
- [x] Create WordCache framework
- [x] Create LocalWordLoader (save/load use case)
- [x] Create WordStorageProtocol
- [x] Write CacheWordUseCaseTests (6 tests)
- [x] Write LoadWordFromCacheUseCaseTests (7 tests)

### Phase 4: Infrastructure Layer
- [x] Create WordCacheInfrastructure framework
- [x] Create SwiftDataWordStore (with in-memory option for tests/previews)
- [x] Create ManagedWord and ManagedMeaning SwiftData models
- [x] Write SwiftDataWordStoreTests (10 tests)

### Phase 5: Composition
- [x] Create HomeUIComposer
- [x] Implement remote-with-fallback pattern (RemoteWithLocalFallbackLoader)
- [x] Wire dependencies in app

### Phase 6: UI Layer - Home
- [x] Create HomeViewState + HomeViewStore + HomeView
- [x] Add language filter
- [x] Add pull-to-refresh
- [x] Add load more
- [x] Add snapshot tests

### Phase 7: UI Layer - Library
- [ ] Create LibraryViewState + LibraryViewModel + LibraryView
- [ ] Add delete functionality
- [ ] Navigate to word detail

### Phase 8: UI Layer - Quiz
- [ ] Create QuizViewState + QuizViewModel + QuizView
- [ ] Implement countdown timer with Clock protocol
- [ ] Multiple choice UI
- [ ] Score tracking

---

## Testing Strategy

### Unit Tests

| Framework | Test Focus |
|-----------|------------|
| WordAPI | Mapper tests, endpoint URL building, loader behavior |
| WordCache | Cache/load behavior, DTO mapping |
| WordCacheInfrastructure | SwiftData persistence, in-memory store |

### Clock Testing (Quiz Feature)

Using [swift-clocks](https://github.com/pointfreeco/swift-clocks) to control time in tests:

```swift
// Production: uses ContinuousClock
// Tests: uses TestClock for deterministic timing

@Test
func countdown_decrements_every_second() async {
    let clock = TestClock()
    let viewModel = QuizViewModel(clock: clock)

    await viewModel.startCountdown(from: 10)

    await clock.advance(by: .seconds(3))

    #expect(viewModel.remainingTime == 7)
}
```

### Snapshot Tests

Using [swift-snapshot-testing](https://github.com/pointfreeco/swift-snapshot-testing) for UI verification:

```swift
@Test
func homeView_withWords_matchesSnapshot() {
    let view = HomeView(
        viewState: .preview(words: Word.samples),
        viewModel: .preview
    )

    assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13)))
}
```

---

## Tech Stack

- **iOS 17+**
- **Swift 6**
- **SwiftUI**
- **SwiftData** (persistence)
- **[ScreenStateKit](https://github.com/anthony1810/ScreenStateKit)** (state management)
- **[swift-clocks](https://github.com/pointfreeco/swift-clocks)** (testable time)
- **[swift-snapshot-testing](https://github.com/pointfreeco/swift-snapshot-testing)** (UI snapshot tests)
- **Swift Testing** (unit tests)

---

## Dependencies

Add these packages to your project:

```swift
// Package.swift or via Xcode SPM

dependencies: [
    .package(url: "https://github.com/anthony1810/ScreenStateKit.git", from: "1.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-clocks.git", from: "1.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.15.0"),
]
```

---

## Getting Started

1. Clone the repository
2. Open `Definery.xcodeproj`
3. Add package dependencies (ScreenStateKit, swift-clocks, swift-snapshot-testing)
4. Build and run

---

## Resources

- [ScreenStateKit](https://github.com/anthony1810/ScreenStateKit) - State management toolkit
- [Wiktionary API](https://en.wiktionary.org/w/api.php) - Word definitions (multi-language support)
- [Random Word API](https://random-word-api.herokuapp.com/home) - Random words
- [swift-clocks](https://github.com/pointfreeco/swift-clocks) - Testable Swift concurrency clocks
- [swift-snapshot-testing](https://github.com/pointfreeco/swift-snapshot-testing) - Snapshot testing library

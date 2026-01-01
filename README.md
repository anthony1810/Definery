# Definery

A word definition and learning iOS app demonstrating **[ScreenStateKit](https://github.com/anthony1810/ScreenStateKit)** - a comprehensive Swift state management toolkit with clean architecture and offline-first capability.

> This project serves as a real-world demo for [ScreenStateKit](https://github.com/anthony1810/ScreenStateKit), showcasing the Three Pillars pattern (State + ViewModel + View) in a production-like app.

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
│  │  - Injects into ViewModels                                           │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                         UI Layer                                     │    │
│  │  - SwiftUI Views (HomeView, LibraryView, QuizView)                  │    │
│  │  - ViewStates (ScreenState subclasses)                               │    │
│  │  - ViewModels (ScreenActionStore actors)                             │    │
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
│ • Meaning        │    │ • WordMapper     │    │ • WordStore (Protocol)   │
│ • WordLoader     │◄───│ • WordsEndpoint  │    │ • LocalWord (Cache DTO)  │
│   (Protocol)     │    │                  │    │                          │
│ • WordCache      │    │ Depends on:      │    │ Depends on:              │
│   (Protocol)     │    │ → WordFeature    │    │ → WordFeature            │
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
| Definitions | [dictionaryapi.dev](https://dictionaryapi.dev) | `GET /api/v2/entries/{lang}/{word}` |

---

## Project Structure

```
Definery/
├── README.md
├── Definery.xcodeproj/
│
├── WordFeature/                      # Domain Layer (Framework)
│   ├── Word.swift                    # Domain model
│   ├── Meaning.swift                 # Value object for word meanings
│   ├── WordLoaderProtocol.swift      # Protocol for loading words
│   └── WordCacheProtocol.swift       # Protocol for caching words
│
├── WordFeatureTests/                 # Domain tests
│   └── WordTests.swift
│
├── WordAPI/                          # API Layer (Framework)
│   ├── HTTPClientProtocol.swift      # HTTP client abstraction
│   ├── URLSessionHTTPClient.swift    # URLSession implementation
│   ├── RemoteWordLoader.swift        # Implements WordLoaderProtocol
│   ├── WordsEndpoint.swift           # URL builder for APIs
│   ├── WordMapper.swift              # Maps API JSON → Word
│   └── RemoteWord.swift              # API DTO (Decodable)
│
├── WordAPITests/                     # API tests
│   ├── RemoteWordLoaderTests.swift
│   ├── WordMapperTests.swift
│   └── WordsEndpointTests.swift
│
├── WordCache/                        # Cache Layer (Framework)
│   ├── LocalWordLoader.swift         # Implements WordLoaderProtocol + WordCache
│   ├── LocalWord.swift               # Cache DTO
│   └── WordStoreProtocol.swift       # Protocol for store implementations
│
├── WordCacheTests/                   # Cache tests
│   └── LocalWordLoaderTests.swift
│
├── WordCacheInfrastructure/          # Infrastructure Layer (Framework)
│   ├── SwiftDataWordStore.swift      # SwiftData implementation
│   └── InMemoryWordStore.swift       # In-memory implementation (testing)
│
├── WordCacheInfrastructureTests/     # Infrastructure tests
│   └── SwiftDataWordStoreTests.swift
│
└── Definery/                         # Main App Target
    ├── DefineryApp.swift             # App entry point
    ├── Composer/
    │   └── WordLoaderComposer.swift  # Wires remote + local with fallback
    └── Features/
        ├── Home/
        │   ├── HomeViewState.swift   # ScreenState subclass
        │   ├── HomeViewModel.swift   # ScreenActionStore actor
        │   └── HomeView.swift        # SwiftUI view
        ├── Library/
        │   ├── LibraryViewState.swift
        │   ├── LibraryViewModel.swift
        │   └── LibraryView.swift
        ├── Quiz/
        │   ├── QuizViewState.swift
        │   ├── QuizViewModel.swift   # Uses Clock for countdown timer
        │   └── QuizView.swift
        └── WordDetail/
            └── WordDetailView.swift
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

### LocalWord (Cache DTO)

```swift
// In WordCache framework - maps to/from Word
struct LocalWord {
    let id: UUID
    let text: String
    let language: String
    let phonetic: String?
    let meanings: [LocalMeaning]
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

### WordCache

```swift
public protocol WordCache {
    func save(_ words: [Word]) async throws
}
```

### WordStore (Infrastructure)

```swift
public protocol WordStore {
    func retrieve() async throws -> [LocalWord]?
    func insert(_ words: [LocalWord]) async throws
    func delete() async throws
}
```

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

### 2. ViewModel (ScreenActionStore actor)

```swift
actor HomeViewModel: ScreenActionStore {
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
    @State private var viewModel: HomeViewModel

    var body: some View {
        // ...
        .onShowLoading($viewState.isLoading)
        .onShowError($viewState.displayError)
        .task {
            await viewModel.binding(state: viewState)
            viewModel.receive(action: .refresh)
        }
    }
}
```

---

## Implementation Progress

### Phase 1: Domain Layer
- [x] Create WordFeature framework
- [x] Create WordLoaderProtocol
- [x] Create WordCache protocol
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
- [ ] Create WordCache framework
- [ ] Create LocalWordLoader
- [ ] Create WordStore protocol
- [ ] Create LocalWord DTO
- [ ] Write LocalWordLoaderTests

### Phase 4: Infrastructure Layer
- [ ] Create WordCacheInfrastructure framework
- [ ] Create SwiftDataWordStore
- [ ] Create InMemoryWordStore
- [ ] Write SwiftDataWordStoreTests

### Phase 5: Composition
- [ ] Create WordLoaderComposer
- [ ] Implement remote-with-fallback pattern
- [ ] Wire dependencies in app

### Phase 6: UI Layer - Home
- [ ] Create HomeViewState + HomeViewModel + HomeView
- [ ] Add language filter
- [ ] Add pull-to-refresh
- [ ] Add load more

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
| WordFeature | Model equality, protocol contracts |
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
- **Swift 5.9+**
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
- [Free Dictionary API](https://dictionaryapi.dev/) - Word definitions
- [Random Word API](https://random-word-api.herokuapp.com/home) - Random words
- [swift-clocks](https://github.com/pointfreeco/swift-clocks) - Testable Swift concurrency clocks
- [swift-snapshot-testing](https://github.com/pointfreeco/swift-snapshot-testing) - Snapshot testing library

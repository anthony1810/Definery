// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "WordCache",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "WordCache", targets: ["WordCache"])
    ],
    dependencies: [
        .package(path: "../WordFeature")
    ],
    targets: [
        .target(
            name: "WordCache",
            dependencies: ["WordFeature"],
            path: "Sources/WordCache"
        ),
        .testTarget(
            name: "WordCacheTests",
            dependencies: ["WordCache", "WordFeature"],
            path: "Tests/WordCacheTests"
        )
    ]
)

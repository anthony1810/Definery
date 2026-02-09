// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "WordCacheInfrastructure",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "WordCacheInfrastructure", targets: ["WordCacheInfrastructure"])
    ],
    dependencies: [
        .package(path: "../WordCache")
    ],
    targets: [
        .target(
            name: "WordCacheInfrastructure",
            dependencies: ["WordCache"],
            path: "Sources/WordCacheInfrastructure"
        ),
        .testTarget(
            name: "WordCacheInfrastructureTests",
            dependencies: ["WordCacheInfrastructure", "WordCache"],
            path: "Tests/WordCacheInfrastructureTests"
        )
    ]
)

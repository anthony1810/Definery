// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "WordFeature",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "WordFeature", targets: ["WordFeature"])
    ],
    targets: [
        .target(
            name: "WordFeature",
            path: "Sources/WordFeature"
        )
    ]
)

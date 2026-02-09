// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "WordAPI",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "WordAPI", targets: ["WordAPI"])
    ],
    dependencies: [
        .package(path: "../WordFeature")
    ],
    targets: [
        .target(
            name: "WordAPI",
            dependencies: ["WordFeature"],
            path: "Sources/WordAPI"
        ),
        .testTarget(
            name: "WordAPITests",
            dependencies: ["WordAPI", "WordFeature"],
            path: "Tests/WordAPITests"
        )
    ]
)

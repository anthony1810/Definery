//
//  SnapshotTestHelpers.swift
//  DefineryTests
//
//  Created by Anthony on 4/1/26.
//

import Foundation
import SnapshotTesting
import UIKit

// MARK: - Custom Device Configs

extension ViewImageConfig {
    /// iPhone 16 Pro / iPhone 17 Pro (393×852 @3x, Dynamic Island safe area)
    static let iPhone16Pro = ViewImageConfig.iPhone16Pro(.portrait)

    static func iPhone16Pro(_ orientation: Orientation) -> ViewImageConfig {
        let safeArea: UIEdgeInsets
        let size: CGSize
        switch orientation {
        case .landscape:
            safeArea = .init(top: 0, left: 59, bottom: 21, right: 59)
            size = .init(width: 852, height: 393)
        case .portrait:
            safeArea = .init(top: 59, left: 0, bottom: 34, right: 0)
            size = .init(width: 393, height: 852)
        }
        return .init(safeArea: safeArea, size: size, traits: .iPhone16Pro(orientation))
    }
}

extension UITraitCollection {
    static func iPhone16Pro(_ orientation: ViewImageConfig.Orientation) -> UITraitCollection {
        let base: [UITraitCollection] = [
            .init(forceTouchCapability: .unavailable),
            .init(layoutDirection: .leftToRight),
            .init(preferredContentSizeCategory: .medium),
            .init(userInterfaceIdiom: .phone),
            .init(displayScale: 3),
        ]
        switch orientation {
        case .landscape:
            return .init(traitsFrom: base + [
                .init(horizontalSizeClass: .regular),
                .init(verticalSizeClass: .compact),
            ])
        case .portrait:
            return .init(traitsFrom: base + [
                .init(horizontalSizeClass: .compact),
                .init(verticalSizeClass: .regular),
            ])
        }
    }
}

// MARK: - Snapshot Directory Resolution

/// Resolves snapshot directory for both local development and CI (Xcode Cloud).
/// - Local: Uses #filePath to find Snapshots folder next to test file
/// - CI: Checks ci_scripts folder (accessible in Xcode Cloud) or test bundle resources
func resolveSnapshotDirectory(
    testClassName: String,
    testName: String,
    file: StaticString
) -> String? {
    let sanitizedTestName = sanitizePathComponent(testName)
    let snapshotFileName = "\(sanitizedTestName).1.png"

    // 1. Check ci_scripts folder (Xcode Cloud copies this folder to test environment)
    let ciScriptsCandidates = [
        // ci_scripts at project root (test-without-building)
        "/Volumes/workspace/repository/ci_scripts/Snapshots/\(testClassName)",
        // Alternative path structure
        URL(fileURLWithPath: "\(file)")
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("ci_scripts")
            .appendingPathComponent("Snapshots")
            .appendingPathComponent(testClassName)
            .path
    ]

    for candidate in ciScriptsCandidates {
        let snapshotPath = (candidate as NSString).appendingPathComponent(snapshotFileName)
        if FileManager.default.fileExists(atPath: snapshotPath) {
            return candidate
        }
    }

    // 2. Check test bundle resources (if snapshots are bundled)
    let testBundle = Bundle(for: BundleToken.self)
    if let resourceURL = testBundle.resourceURL {
        let bundleCandidates = [
            resourceURL.appendingPathComponent("Snapshots").appendingPathComponent(testClassName),
            resourceURL.appendingPathComponent(testClassName)
        ]

        for candidate in bundleCandidates {
            let snapshotFile = candidate.appendingPathComponent(snapshotFileName)
            if FileManager.default.fileExists(atPath: snapshotFile.path) {
                return candidate.path
            }
        }
    }

    // 3. Fall back to file-based path for local development
    let url = URL(fileURLWithPath: "\(file)", isDirectory: false)
    return url
        .deletingLastPathComponent()
        .appendingPathComponent("Snapshots")
        .appendingPathComponent(testClassName)
        .path
}

/// Sanitizes test function name to match snapshot file naming convention
/// Copied from swift-snapshot-testing
func sanitizePathComponent(_ string: String) -> String {
    string
        .replacingOccurrences(of: "\\W+", with: "-", options: .regularExpression)
        .replacingOccurrences(of: "^-|-$", with: "", options: .regularExpression)
}

/// Token class to get the test bundle
final class BundleToken {}

//
//  SnapshotTestHelpers.swift
//  DefineryTests
//
//  Created by Anthony on 4/1/26.
//

import Foundation

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

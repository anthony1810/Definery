//
//  MemoryLeakTracker.swift
//  WordCacheInfrastructureTests
//
//  Created by Anthony on 2/1/26.
//

import Testing
import Foundation

struct MemoryLeakTracker<T: AnyObject> {
    weak var instance: T?
    var sourceLocation: SourceLocation

    func verify() {
        #expect(
            instance == nil,
            "Expected \(String(describing: instance)) to be deallocated. Potential memory leak",
            sourceLocation: sourceLocation
        )
    }
}

//
//  MemoryLeakTracker.swift
//  WordAPITests
//
//  Created by Anthony on 1/1/26.
//

import Testing

struct MemoryLeakTracker {
    weak var instance: AnyObject?
    var sourceLocation: SourceLocation

    func verify() {
        #expect(
            instance == nil,
            "Expected \(String(describing: instance)) to be deallocated. Potential memory leak",
            sourceLocation: sourceLocation
        )
    }
}

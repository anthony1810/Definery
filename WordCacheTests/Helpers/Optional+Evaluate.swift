//
//  Optional+Evaluate.swift
//  Definery
//
//  Created by Anthony on 1/1/26.
//


import Foundation
import Testing

public extension Optional {
  
  /// Evaluate stubs in mock implementations of dependencies
  ///
  /// Stubs should be of type `Result<T, Error>?`.
  /// This method evaluates the stub in 1 of 3 ways:
  ///  1. If the Result is `nil`, the stub has not been set and `XCTFail()` is immediately called
  ///  2. If the Result is `.success`, returns the value
  ///  3. If the Result is `.failure`, throws the wrapped error
  ///
  func evaluate<T>(
    file: StaticString = #file,
    line: UInt = #line
  ) throws -> T where Wrapped == Result<T, Error> {
    switch self {
    case .some(let result):
      return try result.get()
      
    case .none:
      Issue.record("Stub not set")
      throw NSError(domain: "Stub not set error", code: 0)
    }
  }
}
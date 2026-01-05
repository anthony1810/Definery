//
//  AppError.swift
//  Definery
//
//  Created by Anthony on 2/1/26.
//

import Foundation

enum AppError: Error {
  case unauthorized(_ reason: String)
  case unknown
  case abnormalState(_ reason: String)
  case noInternetConnection
  case uploadMultipartDataCountMismatch
}

extension AppError: LocalizedError {
  var errorDescription: String? {
    switch self {
    case .unauthorized:
      String(
        localized: "Authorization required",
        table: "Shared"
      )
    case .noInternetConnection:
      String(
        localized: "No internet connection",
        table: "Shared"
      )
    default:
      String(
        localized: "Something went wrong",
        table: "Shared"
      )
    }
  }

  var failureReason: String? {
    switch self {
    case let .unauthorized(reason):
      reason
    default:
      String(
        localized: "An unknown error has occured", 
        table: "Shared"
      )
    }
  }
}

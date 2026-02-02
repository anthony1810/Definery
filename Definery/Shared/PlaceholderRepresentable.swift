//
//  PlaceholderRepresentable.swift
//  Definery
//
//  Created by Anthony on 2/2/26.
//

import Foundation

/// A protocol for types that can provide placeholder data for skeleton loading effects.
protocol PlaceholderRepresentable {
    static var placeholder: Self { get }
    var isPlaceholder: Bool { get }
}

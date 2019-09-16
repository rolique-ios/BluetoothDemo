//
//  CaseIterable.swift
//  Spyfall
//
//  Created by Bohdan Savych on 9/2/19.
//  Copyright © 2019 bbb. All rights reserved.
//

import Foundation

extension RawRepresentable where Self: CaseIterable {
    static var rawValues: [Self.RawValue] {
        return Self.allCases.map { $0.rawValue }
    }
}

//
//  CGPoint.swift
//  Rolique
//
//  Created by Bohdan Savych on 9/7/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit

func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

func /(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x / rhs.x, y: lhs.y / rhs.y)
}

func *(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
}

// MARK: - Comparable
extension CGPoint: Comparable {
    public static func <(lhs: CGPoint, rhs: CGPoint) -> Bool {
        return lhs.x < rhs.x && lhs.y < rhs.y
    }
    
    public static func <=(lhs: CGPoint, rhs: CGPoint) -> Bool {
        return lhs.x <= rhs.x && lhs.y <= rhs.y
    }
    
    public static func >=(lhs: CGPoint, rhs: CGPoint) -> Bool {
        return lhs.x >= rhs.x && lhs.y >= rhs.y
    }
    
    public static func >(lhs: CGPoint, rhs: CGPoint) -> Bool {
        return lhs.x >= rhs.x && lhs.y >= rhs.y
    }
}

extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(String(describing: self))
    }
}

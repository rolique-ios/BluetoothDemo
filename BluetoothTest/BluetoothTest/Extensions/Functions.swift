//
//  Functions.swift
//  Spyfall
//
//  Created by bbb on 10/16/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import Foundation

public struct This {
    @discardableResult static public func id<T>(_ value: T) -> T {
        return value
    }
}

public func cast<From, To>(_ value: From) -> To? {
    return value as? To
}

@discardableResult public func toClosure<T>(_ value: T) -> (() -> T) {
    return { value }
}

public func printObject(_ object: Any) {
    print(object)
}

public func to<T>(_ function: @escaping (() -> Void)) -> ((T) -> Void) {
    return { _ in
        function()
    }
}

public func to<T, G>(_ function: @escaping (() -> Void)) -> ((T, G) -> Void) {
    return { _, _ in
        function()
    }
}

public func to<T, G, H>(_ function: @escaping (() -> Void)) -> ((T, G, H) -> Void) {
    return { _, _, _ in
        function()
    }
}

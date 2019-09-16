//
//  Result.swift
//  Spyfall
//
//  Created by Bohdan Savych on 7/5/19.
//  Copyright © 2019 bbb. All rights reserved.
//

import Foundation

extension Result {
    var value: Success? {
        if case .success(let value) = self {
            return value
        }
        
        return nil
    }
    
    var error: Failure? {
        if case .failure(let error) = self {
            return error
        }
        
        return nil
    }
}

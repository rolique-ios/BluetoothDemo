//
//  Int.swift
//  Rolique
//
//  Created by Bohdan Savych on 10/13/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation

extension UInt {
    var factorial: UInt {
        if self == 0 { return  1 }
        
        return self * (self - 1).factorial
    }
}

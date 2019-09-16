//
//  DateComponents.swift
//  Rolique
//
//  Created by Bohdan Savych on 8/17/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation

extension DateComponents {
    var isMonday: Bool {
        return self.weekday == 2
    }
    
    var isSunday: Bool {
        return self.weekday == 1
    }
}

//
//  Device.swift
//  BluetoothTest
//
//  Created by Bohdan Savych on 9/13/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import Foundation
import CoreBluetooth

struct Device: Hashable, Equatable {
    static func == (lhs: Device, rhs: Device) -> Bool {
        return lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name ?? "")
    }
    
    var cbperiferal: CBPeripheral
    var name: String?
    var rssi: String?
    var advertisementData = [String: Any]()
    var state: String?
}

extension Device: CustomStringConvertible {
    var description: String {
        return "name: \(name ?? "null"), state: \(state ?? "null"), rssi: \(rssi ?? "null")\nadvertisementData: \(advertisementData)"
    }
}

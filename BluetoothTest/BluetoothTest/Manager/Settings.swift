//
//  Settings.swift
//  BluetoothTest
//
//  Created by Andrii on 9/15/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import Foundation
import CoreBluetooth

class Settings: NSObject {
  static let main: Settings = Settings()
  
  private override init() {
    super.init()
  }
  
  func update() {
    
  }
  
  var transferServiceUUID = CBUUID(string: "E20A39F4-73F5-4BC4-A12F-17D1AD666661")
  var transferCharacteristicUUID = CBUUID(string: "08590F7E-DB05-467E-8757-72F6F66666D4")
  
  func updateWithType(_ type: UUIDType, nsuuid: UUID) {
    switch type {
    case .transferServiceUUID: transferServiceUUID = CBUUID(nsuuid: nsuuid)
    case .transferCharacteristicUUID: transferCharacteristicUUID = CBUUID(nsuuid: nsuuid)
    }
  }
  
}


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
  
  var cUUID1 = CBUUID(string: "2C270F0C-C9D3-4E56-ACCD-15621FA1568E")
  var cUUID2 = CBUUID(string: "6082238A-C138-42B0-9562-44A1642BE5A5")
  var notifyUUID = CBUUID(string: "83951652-DF2E-4CF7-8E45-FCE84073F705")
  var rwUUID = CBUUID(string: "3ECDBC04-441D-4A7A-A62E-43081CD67ED7")
  var transferServiceUUID = CBUUID(string: "E20A39F4-73F5-4BC4-A12F-17D1AD666661")
  var transferCharacteristicUUID = CBUUID(string: "08590F7E-DB05-467E-8757-72F6F66666D4")
  
  
  func updateWithType(_ type: UUIDType, nsuuid: UUID) {
    switch type {
    case .cUUID1: cUUID1 = CBUUID(nsuuid: nsuuid)
    case .cUUID2: cUUID2 = CBUUID(nsuuid: nsuuid)
    case .notifyUUID: notifyUUID = CBUUID(nsuuid: nsuuid)
    case .rwUUID: rwUUID = CBUUID(nsuuid: nsuuid)
    case .transferServiceUUID: transferServiceUUID = CBUUID(nsuuid: nsuuid)
    case .transferCharacteristicUUID: transferCharacteristicUUID = CBUUID(nsuuid: nsuuid)
    }
  }
  
}


//
//  RoleViewController.swift
//  BluetoothTest
//
//  Created by Bohdan Savych on 9/13/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import CoreBluetooth

enum UUIDType {
  case cUUID1, cUUID2, notifyUUID, rwUUID, transferServiceUUID, transferCharacteristicUUID
  var defaultValue: String {
    switch self {
    case .cUUID1: return Settings.main.cUUID1.uuidString
    case .cUUID2: return Settings.main.cUUID2.uuidString
    case .notifyUUID: return Settings.main.notifyUUID.uuidString
    case .rwUUID: return Settings.main.rwUUID.uuidString
    case .transferServiceUUID: return Settings.main.transferServiceUUID.uuidString
    case .transferCharacteristicUUID: return Settings.main.transferCharacteristicUUID.uuidString
    }
  }
}

class FieldString {
  var type: UUIDType
  var field: UITextField
  var text: String? {
    set(newValue) {
      field.text = newValue
    }
    get { return field.text }
  }
  var isValid: Bool {
    return  UUID(uuidString: text ?? "") != nil
  }
  
  init(type: UUIDType, field: UITextField) {
    self.type = type
    self.field = field
    self.text = type.defaultValue
  }
}

final class RoleViewController: UIViewController {
  
  @IBOutlet weak var cUUID1Field: UITextField!
  @IBOutlet weak var cUUID2Field: UITextField!
  @IBOutlet weak var notifyUUIDField: UITextField!
  @IBOutlet weak var rwUUIDField: UITextField!
  @IBOutlet weak var transferServiceUUIDField: UITextField!
  @IBOutlet weak var transferCharacteristicUUIDField: UITextField!
  
  lazy var fieldStrings: [FieldString] = {
    return [
      FieldString(type: .cUUID1, field: cUUID1Field),
      FieldString(type: .cUUID2, field: cUUID2Field),
      FieldString(type: .notifyUUID, field: notifyUUIDField),
      FieldString(type: .rwUUID, field: rwUUIDField),
      FieldString(type: .transferServiceUUID, field: transferServiceUUIDField),
      FieldString(type: .transferCharacteristicUUID, field: transferCharacteristicUUIDField)
    ]}()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    fieldStrings.forEach {
      $0.field.delegate = self }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    updateUI()
  }
  
  @objc func updateUI() {
    fieldStrings.forEach {
      $0.field.textColor = $0.isValid ? .black : .red
    }
  }
  
  @objc func updateSettings() {
    fieldStrings.forEach { item in
      if let uuid = UUID(uuidString: item.text ?? "") {
        Settings.main.updateWithType(item.type, nsuuid: uuid)
      }
    }
  }
  
  @objc func showWrongUUIDAlert() {
    Spitter.showOkAlertOnPVC("this string is not valid UUID")
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    Locator.main.start()
  }
  
  @IBAction func centralTouchUpInside(sender: UIButton) {
    let vc = (self.storyboard?.instantiateViewController(withIdentifier: "CentralViewController"))!
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
  @IBAction func peripheraTouchUpInside(sender: UIButton) {
    let vc = (self.storyboard?.instantiateViewController(withIdentifier: "PeripheralViewController"))!
    self.navigationController?.pushViewController(vc, animated: true)
  }
}

extension RoleViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    guard let item = fieldStrings.first(where: { $0.field == textField }) else {
      return false
    }
    if item.isValid { view.endEditing(false) } else { showWrongUUIDAlert() }
    updateUI()
    updateSettings()
    NotificationCenter.default.post(name: NSNotification.Name.onUpdateSettings, object: nil)
    return item.isValid
  }
  
}

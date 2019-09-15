//
//  RoleViewController.swift
//  BluetoothTest
//
//  Created by Bohdan Savych on 9/13/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import CoreBluetooth

final class RoleViewController: UIViewController {
  
  @IBOutlet weak var cUUID1Field: UITextField!
  @IBOutlet weak var cUUID2Field: UITextField!
  @IBOutlet weak var notifyUUIDField: UITextField!
  @IBOutlet weak var rwUUIDField: UITextField!
  @IBOutlet weak var transferServiceUUIDField: UITextField!
  @IBOutlet weak var transferCharacteristicUUIDField: UITextField!

  var fields: [UITextField] {
    return [cUUID1Field, cUUID2Field, notifyUUIDField, rwUUIDField, transferServiceUUIDField, transferCharacteristicUUIDField]
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    fields.forEach {
      $0.delegate = self }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    updateUI()
  }
  
  @objc func updateUI() {
    cUUID1Field.text = Settings.main.cUUID1.uuidString
    cUUID2Field.text = Settings.main.cUUID2.uuidString
    notifyUUIDField.text = Settings.main.notifyUUID.uuidString
    rwUUIDField.text = Settings.main.rwUUID.uuidString
    transferServiceUUIDField.text = Settings.main.transferServiceUUID.uuidString
    transferCharacteristicUUIDField.text = Settings.main.transferCharacteristicUUID.uuidString
  }
  
  @objc func updateSettigns() {
    Settings.main.cUUID1 = CBUUID(string: cUUID1Field.text ?? "")
    Settings.main.cUUID2 = CBUUID(string: cUUID2Field.text ?? "")
    Settings.main.notifyUUID = CBUUID(string: notifyUUIDField.text ?? "")
    Settings.main.rwUUID = CBUUID(string: rwUUIDField.text ?? "")
    Settings.main.transferServiceUUID = CBUUID(string: transferServiceUUIDField.text ?? "")
    Settings.main.transferCharacteristicUUID = CBUUID(string: transferCharacteristicUUIDField.text ?? "")
    NotificationCenter.default.post(name: Notification.Name.onUpdateSettings, object: nil, userInfo: nil)
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
    self.view.endEditing(false)
    return true
  }
  
  func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
    self.updateSettigns()
  }
}

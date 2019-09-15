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
  @IBOutlet weak var notifyChracatorUUIDField: UITextField!
  @IBOutlet weak var rwChracatorUUIDField: UITextField!

  var fields: [UITextField] {
    return [cUUID1Field, cUUID2Field, notifyUUIDField, rwUUIDField, notifyChracatorUUIDField, rwChracatorUUIDField]
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    fields.forEach { $0.delegate = self }
  }
  
  @objc func updateSettigns() {
    Settings.main.cUUID1 = CBUUID(string: cUUID1Field.text ?? "")
    Settings.main.cUUID2 = CBUUID(string: cUUID2Field.text ?? "")
    Settings.main.notifyUUID = CBUUID(string: notifyUUIDField.text ?? "")
    Settings.main.rwUUID = CBUUID(string: rwUUIDField.text ?? "")
    Settings.main.notifyChracatorUUID = CBUUID(string: notifyChracatorUUIDField.text ?? "")
    Settings.main.rwChracatorUUID = CBUUID(string: rwChracatorUUIDField.text ?? "")
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

//
//  RoleViewController.swift
//  BluetoothTest
//
//  Created by Bohdan Savych on 9/13/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit

final class RoleViewController: UIViewController {
  
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

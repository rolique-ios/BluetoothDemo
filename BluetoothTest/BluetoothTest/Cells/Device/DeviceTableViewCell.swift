//
//  DeviceTableViewCell.swift
//  BluetoothTest
//
//  Created by Bohdan Savych on 9/13/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit

final class DeviceTableViewCell: UITableViewCell {
    @IBOutlet weak var deviceInfoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    func configure(device: Device) {
        deviceInfoLabel.text = device.description
    }
}

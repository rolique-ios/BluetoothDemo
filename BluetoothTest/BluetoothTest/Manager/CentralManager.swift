//
//  CentralManager.swift
//  BluetoothTest
//
//  Created by Bohdan Savych on 9/13/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol CentralManagerDelegate: class {
    func didUpdateConnectedDevices(_ devices: [Device])
    func didUpdateDiscoveredDevices(_ devices: [Device])
    func didUpdateState(_ string: String)
    func didFailToConnect(to device: String, error: Error?)
}

final class CentralManager: NSObject {
    var centralManager: CBCentralManager!
    weak var delegate: CentralManagerDelegate?

    var discovered = Set<Device>() {
        didSet {
            self.delegate?.didUpdateDiscoveredDevices(Array(discovered).sorted(by: { dev1, dev2 in return (dev1.name ?? "") > (dev2.name ?? "") }))
        }
    }
    var connected = Set<Device>() {
        didSet {
            self.delegate?.didUpdateConnectedDevices(Array(connected).sorted(by: { dev1, dev2 in return (dev1.name ?? "") > (dev2.name ?? "") }))
        }
    }
    
    var connectingDevice: Device?
    
    init(delegate: CentralManagerDelegate) {
        super.init()
        
        self.delegate = delegate
        self.centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main, options: nil)
    }
    
    func start() {
        
    }
    
    func startScanning() {
        self.centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    
    func connect(to device: Device) {
        log("started connecting to \(device.name)")
        self.connectingDevice = device
        self.centralManager?.connect(device.cbperiferal, options: [CBConnectPeripheralOptionNotifyOnConnectionKey:true, CBConnectPeripheralOptionNotifyOnDisconnectionKey:true])
    }
}

// MARK: - CBCentralManagerDelegate
extension CentralManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        log("central did change state")
        switch central.state {
        case .poweredOff:
            self.delegate?.didUpdateState("Powered Off")
            log("poweredOff")
        case .poweredOn:
            log("poweredOn")
            self.delegate?.didUpdateState("Powered On")
            self.startScanning()
        case .resetting:
            log("resetting")
            self.delegate?.didUpdateState("Resetting")
        case .unauthorized:
            log("unauthorized")
            self.delegate?.didUpdateState("Unauthorized")
        case .unknown:
            log("unknown")
            self.delegate?.didUpdateState("Unknown")
        case .unsupported:
            log("unsupported")
            self.delegate?.didUpdateState("Unsupported")
        default:
            self.delegate?.didUpdateState("Unknown default state")
            log("unknown default state: \(central.state)")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        let device = Device(cbperiferal: peripheral, name: peripheral.name, rssi: nil, advertisementData: [:], state: "\(peripheral.state.description)")
        self.connected.remove(device)
        log("didDisconnectPeripheral")
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        let device = Device(cbperiferal: peripheral, name: peripheral.name, rssi: nil, advertisementData: [:], state: "\(peripheral.state.description)")
        self.discovered.remove(device)
        self.connected.insert(device)
        self.connectingDevice?.cbperiferal.delegate = self
        self.connectingDevice?.cbperiferal.readRSSI()
        self.connectingDevice?.cbperiferal.discoverServices([Settings.main.notifyUUID, Settings.main.rwUUID])

        log("discoverServices")
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        log("central will restore state dict: \(dict)")
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        self.delegate?.didFailToConnect(to: peripheral.name ?? "", error: error)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let device = Device(cbperiferal: peripheral, name: peripheral.name, rssi: String("\(RSSI)"), advertisementData: advertisementData, state: "\(peripheral.state.description)")
        
        if !discovered.contains(device) && !connected.contains(device) {
            self.discovered.insert(device)
        }
        device.cbperiferal.delegate = self
    }
}

// MARK: - CBPeripheralDelegate
extension CentralManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        log("didDiscoverServices")
        guard let services = peripheral.services else {         log("no services available"); return }
        
        if services.isEmpty {
            log("there are not services available")
        }
        
        for service in services {
            log("service is \(service.uuid.uuidString)")
            if service.uuid == Settings.main.notifyUUID {
                peripheral.discoverCharacteristics([Settings.main.cUUID1], for: service)
            }
            if service.uuid == Settings.main.rwUUID {
                peripheral.discoverCharacteristics([Settings.main.cUUID2], for: service)
            }
        }
    }
    
    /// Invoked when you write data to a characteristic’s value.
    /// This method is invoked only when your app calls the writeValue(_:for:type:) method with the withResponse constant specified as the write type
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let data = characteristic.value
        
        if data != nil {
            log("did update value is \(NSString.init(data: data!, encoding: String.Encoding.utf8.rawValue)!)")
        } else {
            log("did update value is nil")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            log("discover characteristic \(characteristic)")
            if characteristic.uuid == Settings.main.cUUID2 {
                let readData = ("uwei").data(using: .utf8)!
                peripheral.writeValue(readData, for: characteristic, type: CBCharacteristicWriteType.withResponse)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        log("RSSI is \(RSSI.floatValue)")
    }
}

extension CBPeripheralState: CustomStringConvertible {
    public var description: String {
        switch self {
        case .connected:
            return "connected"
        case .connecting:
            return "connecting"
        case .disconnected:
            return "disconnected"
        case .disconnecting:
            return "disconnecting"
        @unknown default:
            return "default"
        }
    }
}

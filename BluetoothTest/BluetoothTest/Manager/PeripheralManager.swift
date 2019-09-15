//
//  PeripheralManager.swift
//  BluetoothTest
//
//  Created by Bohdan Savych on 9/13/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol PeripheralManagerDelegate: class {
    func startedBroadcasting()
    func didSubscribe(to device: String)
    func didUnsubscribe(to device: String)
    func didUpdateState(_ string: String)
}

final class PeripheralManager: NSObject {

    private var sendDataTimer:Timer?
    private var notifyService: CBMutableService?
    private var rwService: CBMutableService?
    private var notifyCharacteristic: CBMutableCharacteristic?
    private var rwableCharacteristic: CBMutableCharacteristic?
    
    weak var delegate: PeripheralManagerDelegate?
    var peripheralManager: CBPeripheralManager!
    
    init(delegate: PeripheralManagerDelegate) {
        super.init()
        
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: DispatchQueue.main, options: [CBCentralManagerOptionShowPowerAlertKey:true])
        self.delegate = delegate
    }
    
    
    func broadcast(data: [String: Any]) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            self.peripheralManager.startAdvertising([CBAdvertisementDataLocalNameKey:"uwei service" , CBAdvertisementDataServiceUUIDsKey : [Settings.main.notifyUUID, Settings.main.rwUUID]])
        }
    }
    
    func setPeripheralService() {
        notifyCharacteristic = CBMutableCharacteristic(type: Settings.main.cUUID1, properties: .notify, value: nil, permissions: .readable)
        rwableCharacteristic = CBMutableCharacteristic(type: Settings.main.cUUID2, properties: [.read, .write], value: nil, permissions: [.writeable, .readable])
        
        notifyService = CBMutableService(type: Settings.main.notifyUUID, primary: true)
        notifyService?.characteristics = [notifyCharacteristic!]
        
        rwService = CBMutableService(type: Settings.main.rwUUID, primary: true)
        rwService?.characteristics = [rwableCharacteristic!]
        
        peripheralManager?.add(notifyService!)
        peripheralManager?.add(rwService!)
    }
    
    @objc func sendCurrentTime() -> Void {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd hh:mm:ss"
        let dateString = dateFormatter.string(from: Date())
        
        // If the length of the value parameter exceeds the length of the maximumUpdateValueLength property of a subscribed CBCentral, the value parameter is truncated accordingly.
        let didSend = peripheralManager!.updateValue((dateString as NSString).data(using: String.Encoding.utf8.rawValue)!, for: notifyCharacteristic!, onSubscribedCentrals: nil)
        print("send result \(didSend)")
    }
}

extension PeripheralManager: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("peripheral did change state")
        switch peripheral.state {
        case .poweredOff:
            self.delegate?.didUpdateState("Powered Off")
            self.setPeripheralService()
        case .poweredOn:
            print("poweredOn")
            peripheralManager?.removeAllServices()

            self.delegate?.didUpdateState("Powered On")
        case .resetting:
            print("resetting")
            self.delegate?.didUpdateState("Resetting")
        case .unauthorized:
            print("unauthorized")
            self.delegate?.didUpdateState("Unauthorized")
        case .unknown:
            print("unknown")
            self.delegate?.didUpdateState("Unknown")
        case .unsupported:
            print("unsupported")
            self.delegate?.didUpdateState("Unsupported")
        default:
            print("unknown default state: \(peripheral.state)")
        }
        
    }
    
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        print("peripheralManagerIsReady toUpdateSubscribers: \(peripheral)")
        sendDataTimer?.fire()
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        self.delegate?.startedBroadcasting()
        print("peripheralManagerDidStartAdvertising peripheral: \(peripheral), error: \(error?.localizedDescription ?? "")")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        print("peripheral didReceiveRead \(request)")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String : Any]) {
        print("peripheral willRestoreState \(dict)")
        
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        print("peripheral didAdd \(service), error: \(error?.localizedDescription ?? "")")
        
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        print("didReceiveWrite")
        let request = requests.first
        if request?.characteristic == rwableCharacteristic {
            let c = request?.characteristic as! CBMutableCharacteristic
            c.value = request?.value
            peripheral.respond(to: request!, withResult: .success)
            print("get data from centeral is \(String(data: c.value!, encoding: .utf8)!)")
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didOpen channel: CBL2CAPChannel?, error: Error?) {
        print("peripheral didOpen \(channel), error: \(error?.localizedDescription ?? "")")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didPublishL2CAPChannel PSM: CBL2CAPPSM, error: Error?) {
        print("peripheral didPublishL2CAPChannel \(PSM), error: \(error?.localizedDescription ?? "")")
        
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didUnpublishL2CAPChannel PSM: CBL2CAPPSM, error: Error?) {
        print("peripheral didUnpublishL2CAPChannel \(PSM), error: \(error?.localizedDescription ?? "")")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        self.delegate?.didSubscribe(to: "central")
        sendDataTimer?.invalidate()
        sendDataTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(sendCurrentTime), userInfo: characteristic, repeats: true)
        sendDataTimer?.fire()
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        self.delegate?.didUnsubscribe(to: "central")
        sendDataTimer?.invalidate()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            print(service)
        }
    }
}



//Services and Characteristics
//Advertising packets are very small and cannot contain a great deal of information. To share more data, a central needs to connect to a peripheral.
//
//The peripheral’s data is organized into services and characteristics:
//
//Service: a collection of data and associated behaviors describing a specific function or feature of a peripheral. For example, a heart rate sensor has a Heart Rate service. A peripheral can have more than one service.
//Characteristic: provides further details about a peripheral’s service. For example, the Heart Rate service contains a Heart Rate Measurement characteristic that contains the beats per minute data. A service can have more than one characteristic. Another characteristic that the Heart Rate service may have is Body Sensor Location, which is simply a string that describes the intended body location of the sensor.

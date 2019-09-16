//
//  ViewController.swift
//  BluetoothTest
//
//  Created by Bohdan Savych on 9/13/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import CoreBluetooth

final class PeripheralViewController: UIViewController {
    
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var advertisingSwitch: UISwitch!
    @IBOutlet private weak var logsTextView: UITextView!
    @IBOutlet private weak var locationLabel: UILabel!
    
    private var peripheralManager: CBPeripheralManager?
    private var transferCharacteristic: CBMutableCharacteristic?
    
//    private var sendingEOM = false;
//    private var dataToSend: Data?
//    private var sendDataIndex: Int?
    
    private lazy var locationUpdateTimer: Timer = {
        return Timer(timeInterval: 1, target: self, selector: #selector(updateLocationLabel), userInfo: nil, repeats: true)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        [textView, logsTextView].forEach { $0?.delegate = self }
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        //    NotificationCenter.default.addObserver(self, selector: #selector(updateLocationLabel), name: Notification.Name.onUpdatLocation, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateLocationLabel()
        self.textView.becomeFirstResponder()
        RunLoop.main.add(locationUpdateTimer, forMode: .default)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        locationUpdateTimer.invalidate()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        peripheralManager?.stopAdvertising()
    }
    
    @objc func updateLocationLabel() {
        self.locationLabel.text = Locator.main.location?.printed
        self.sendAllData()
    }
    
    deinit {
        print("☠️\(String.init(describing: self))☠️")
    }
}

// MARK: - Actions
extension PeripheralViewController {
    /** Start advertising
     */
    @IBAction func switchChanged(_ sender: UISwitch) {
        if advertisingSwitch.isOn {
            // All we advertise is our service's UUID
            peripheralManager!.startAdvertising([
                CBAdvertisementDataServiceUUIDsKey : [Settings.main.transferServiceUUID]
            ])
        } else {
            peripheralManager?.stopAdvertising()
        }
    }
    
    @IBAction func done(sender: UIBarButtonItem) {
        self.view.endEditing(true)
    }
}

extension PeripheralViewController: CBPeripheralManagerDelegate {
    /** Required protocol method.  A full app should take care of all the possible states,
     *  but we're just waiting for  to know when the CBPeripheralManager is ready
     */
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        // Opt out from any other state
        if (peripheral.state != .poweredOn) {
            return
        }
        
        // We're in CBPeripheralManagerStatePoweredOn state...
        logsTextView?.text = (logsTextView?.text ?? "") + "\nPowered on."
        logsTextView.scrollRangeToVisible(NSMakeRange(logsTextView.text.count - 1, 1))
        
        // ... so build our service.
        
        // Start with the CBMutableCharacteristic
        transferCharacteristic = CBMutableCharacteristic(
            type: Settings.main.transferCharacteristicUUID,
            properties: CBCharacteristicProperties.notify,
            value: nil,
            permissions: CBAttributePermissions.readable
        )
        
        // Then the service
        let transferService = CBMutableService(
            type: Settings.main.transferServiceUUID,
            primary: true
        )
        
        // Add the characteristic to the service
        transferService.characteristics = [transferCharacteristic!]
        
        // And add it to the peripheral manager
        peripheralManager?.add(transferService)
    }
    
    /** Catch when someone subscribes to our characteristic, then start sending them data
     */
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        logsTextView?.text = (logsTextView?.text ?? "") + "\nCentral subscribed to characteristic."
        logsTextView.scrollRangeToVisible(NSMakeRange(logsTextView.text.count - 1, 1))
        
//        // Get the data
//        dataToSend = ((Locator.main.location?.jsonString ?? "") + "\n" + textView.text).data(using: String.Encoding.utf8)
//
//        // Reset the index
//        sendDataIndex = 0;
        
        // Start sending
        sendAllData()
    }
    
    /** Recognise when the central unsubscribes
     */
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        logsTextView?.text = (logsTextView?.text ?? "") + "\nCentral unsubscribed from characteristic"
        logsTextView.scrollRangeToVisible(NSMakeRange(logsTextView.text.count - 1, 1))
    }
    
    // First up, check if we're meant to be sending an EOM
    
    /** Sends the next amount of data to the connected central
     */
//    fileprivate func sendData() {
//        if sendingEOM {
//            // send it
//            let didSend = peripheralManager?.updateValue(
//                "EOM".data(using: String.Encoding.utf8)!,
//                for: transferCharacteristic!,
//                onSubscribedCentrals: nil
//            )
//
//            // Did it send?
//            if (didSend == true) {
//
//                // It did, so mark it as sent
//                sendingEOM = false
//            }
//
//            // It didn't send, so we'll exit and wait for peripheralManagerIsReadyToUpdateSubscribers to call sendData again
//            return
//        }
//
//        // We're not sending an EOM, so we're sending data
//
//        // Is there any left to send?
//        guard sendDataIndex < dataToSend?.count else {
//            // No data left.  Do nothing
//            return
//        }
//
//        // There's data left, so send until the callback fails, or we're done.
//        var didSend = true
//
//        while didSend {
//            // Make the next chunk
//
//            // Work out how big it should be
//            var amountToSend = dataToSend!.count - sendDataIndex!;
//
//            // Can't be longer than 20 bytes
//            if (amountToSend > NOTIFY_MTU) {
//                amountToSend = NOTIFY_MTU;
//            }
//
//            // Copy out the data we want
//            let chunk = dataToSend!.withUnsafeBytes{(body: UnsafePointer<UInt8>) in
//                return Data(
//                    bytes: body + sendDataIndex!,
//                    count: amountToSend
//                )
//            }
//
//            // Send it
//            didSend = peripheralManager!.updateValue(
//                chunk as Data,
//                for: transferCharacteristic!,
//                onSubscribedCentrals: nil
//            )
//
//            // If it didn't work, drop out and wait for the callback
//            if (!didSend) {
//                return
//            }
//
//            let stringFromData = NSString(
//                data: chunk as Data,
//                encoding: String.Encoding.utf8.rawValue
//            )
//
//            logsTextView?.text = (logsTextView?.text ?? "") + "\nSent."
//            logsTextView.scrollRangeToVisible(NSMakeRange(logsTextView.text.count - 1, 1))
//
//            // It did send, so update our index
//            sendDataIndex! += amountToSend;
//
//            // Was it the last one?
//            if (sendDataIndex! >= dataToSend!.count) {
//
//                // It was - send an EOM
//
//                // Set this so if the send fails, we'll send it next time
//                sendingEOM = true
//
//                // Send it
//                let eomSent = peripheralManager!.updateValue(
//                    "EOM".data(using: String.Encoding.utf8)!,
//                    for: transferCharacteristic!,
//                    onSubscribedCentrals: nil
//                )
//
//                if (eomSent) {
//                    // It sent, we're all done
//                    sendingEOM = false
//                    logsTextView?.text = (logsTextView?.text ?? "") + "\nSent: EOM."
//                    logsTextView.scrollRangeToVisible(NSMakeRange(logsTextView.text.count - 1, 1))
//                }
//
//                return
//            }
//        }
//    }
    
    func sendAllData() {
        guard let transferCharacteristic = transferCharacteristic, advertisingSwitch.isOn else { return }
        
        print("send all data")
        let data = ((Locator.main.location?.jsonString ?? "") + "\n" + textView.text).data(using: String.Encoding.utf8)!
        print("data size \(data.count) bytes")
        let didSend = peripheralManager?.updateValue(
            data,
            for: transferCharacteristic,
            onSubscribedCentrals: nil
        )
        
        if didSend == true {
            logsTextView?.text = (logsTextView?.text ?? "") + "\nData sent successfully"
        } else {
            logsTextView?.text = (logsTextView?.text ?? "") + "\nData wasn't sent"
        }
    }
    
    /** This callback comes in when the PeripheralManager is ready to send the next chunk of data.
     *  This is to ensure that packets will arrive in the order they are sent
     */
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        // Start sending again
        sendAllData()
    }
    
    /** This is called when a change happens, so we know to stop advertising
     */
    func textViewDidChange(_ textView: UITextView) {
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            logsTextView?.text = (logsTextView?.text ?? "") + "\n\(error.localizedDescription)."
            logsTextView.scrollRangeToVisible(NSMakeRange(logsTextView.text.count - 1, 1))
        }
    }
}

extension PeripheralViewController: UITextViewDelegate {
    
}

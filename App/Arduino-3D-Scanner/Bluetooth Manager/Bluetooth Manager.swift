//
//  Bluetooth Manager.swift
//  Arduino-3D-Scanner
//
//  Created by Leonardo Larrañaga on 4/28/24.
//

import CoreBluetooth
import SwiftUI

class BluetoothManager: NSObject, ObservableObject {
    
    @Published var isBluetoothOn = false
    @Published var isDiscoveringPeripherals = false
    
    @Published var connectedPeripheral: CBPeripheral? = nil
    
    @Published var discoveredPeripherals = [CBPeripheral]()
    @Published var discoveredCharacteristics = [CBCharacteristic]()
    @Published var writableCharacteristic: CBCharacteristic? = nil
    @Published var discoveredServices = [CBService]()
    
    @Published var bluetoothAnimation = false

    private var centralManager: CBCentralManager! = nil
    
    @Published var errorDescription = ""
    @Published var showAlert = false
    
    @Published var readString = ""
    @Published var waitingForReceivedConfirmation = false
    
    // Initialize manager.
    override init () {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
    }
    
    // Start scan.
    func startScan() {
        centralManager?.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        isDiscoveringPeripherals = true
        print("Scanning for peripherals.")
    }
    
    // Stop scan.
    func stopScan() {
        centralManager.stopScan()
        isDiscoveringPeripherals = false
        print("Scanning stopped.")
    }
    
    // Get name of peripheral.
    func getName(of peripheral: CBPeripheral?, advertisementData: [String : Any]? = nil) -> String {
        peripheral?.name ?? advertisementData?[CBAdvertisementDataLocalNameKey] as? String ?? "Unknown peripheral"
    }
    
    // Connect to peripheral.
    func connect(to peripheral: CBPeripheral) {
        centralManager.connect(peripheral, options: [
            CBCentralManagerOptionShowPowerAlertKey: true,
            CBConnectPeripheralOptionNotifyOnDisconnectionKey: true
        ])
    }
    
    // Disconnect from peripheral.
    func disconnectPeripheral() {
        if let connectedPeripheral {
            centralManager.cancelPeripheralConnection(connectedPeripheral)
        }
    }
    
    // Send string to writable characteristic.
    func send(_ string: String) {
        if writableCharacteristic == nil {
            disconnectPeripheral()
            return
        }
        
        withAnimation {
            waitingForReceivedConfirmation = true
        }
        
        if let connectedPeripheral, let writableCharacteristic, let data = string.data(using: .utf8) {
            print(string)
            connectedPeripheral.writeValue(data, for: writableCharacteristic, type: .withResponse)
        }
    }
}

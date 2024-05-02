//
//  CBCentral Manager Delegate.swift
//  Arduino-3D-Scanner
//
//  Created by Leonardo Larrañaga on 5/1/24.
//

import CoreBluetooth

extension BluetoothManager: CBCentralManagerDelegate {
    
    // Manager did connect to a peripheral.
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectedPeripheral = peripheral
        connectedPeripheral?.delegate = self
        connectedPeripheral?.discoverServices(nil)
        bluetoothAnimation = false
        print("Connected to peripheral \(getName(of: peripheral)).")
        stopScan()
    }
    
    // Peripheral got disconnected.
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        if let error {
            showAlert = true
            errorDescription = String(describing: error.localizedDescription)
        }
        
        print("Disconnected from peripheral. \(String(describing: error?.localizedDescription))")
        
        discoveredPeripherals = []
        discoveredServices = []
        discoveredCharacteristics = []
        connectedPeripheral = nil
        bluetoothAnimation = false
    }
    
    // Manager failed to connect to peripheral.
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: (any Error)?) {
        if let error {
            showAlert = true
            errorDescription = error.localizedDescription
        }
        
        print("Manager couldn't connect to \(getName(of: peripheral)).")
        discoveredPeripherals = []
        connectedPeripheral = nil
    }
    
    // Manager updated its state.
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("State changed.")
        switch central.state {
        case .resetting:
            errorDescription = "Bluetooth is resetting."
            showAlert = true
            isDiscoveringPeripherals = false
        case .unsupported:
            errorDescription = "Bluetooth is unsupported."
            showAlert = true
        case .unauthorized:
            errorDescription = "Bluetooth is aunauthorized."
            showAlert = true
        case .poweredOff:
            print("Bluetooth is powered off.")
            isBluetoothOn = false
            isDiscoveringPeripherals = false
            stopScan()
        case .poweredOn:
            print("Bluetooth is powered on.")
            isBluetoothOn = true
        default:
            errorDescription = "Bluetooth state unknown."
            isDiscoveringPeripherals = false
        }
    }
    
    // Manager discovered peripheral.
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard RSSI.intValue <= 0 else { return print("Peripheral \(String(describing: peripheral.name)) doesn't have enough strength signal.") }
        
        if !discoveredPeripherals.contains(peripheral) {
            print("Discovered peripheral: \(getName(of: peripheral, advertisementData: advertisementData))")
            discoveredPeripherals.append(peripheral)
        }
    }
}

//
//  Peripheral Delegate.swift
//  Arduino-3D-Scanner
//
//  Created by Leonardo Larrañaga on 5/1/24.
//

import CoreBluetooth
import SwiftUI

extension BluetoothManager: CBPeripheralDelegate {
    
    // Manager discovered services from peripheral.
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        if let error {
            print("Error discovering services. \(error.localizedDescription)")
            errorDescription = error.localizedDescription
            showAlert = true
            return
        }
        
        print("Services discovered from peripheral \(getName(of: peripheral))")
        if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
                discoveredServices.append(service)
            }
        }
    }
    
    // Manager discovered characteristics for services of a peripheral.
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        if let error {
            print("Error discovering characteristics. \(error.localizedDescription)")
            errorDescription = error.localizedDescription
            showAlert = true
            return
        }
        
        print("Discovered characteristics of service \(service)")
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                discoveredCharacteristics.append(characteristic)
                peripheral.readValue(for: characteristic)
                
                let properties = String(characteristic.properties.rawValue, radix: 2)
                if properties.count >= 3 {
                    if properties.reversed()[3] == "1" {
                        writableCharacteristic = characteristic
                        peripheral.setNotifyValue(true, for: characteristic)
                    }
                }
            }
        }
    }
    
    // Characteristic of a service updated its value.
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        if let error {
            print("Error updating characteristic \(characteristic) value. \(error.localizedDescription)")
            errorDescription = error.localizedDescription
            showAlert = true
            return
        }
        
        if let value = characteristic.value {
            print("Characteristic updated value for: \(characteristic)\n")
            
            let string = (String(data: value, encoding: .utf8) ?? String(describing: value)).trimmingCharacters(in: .newlines)
            
            print(string)
            
            // Message was received.
            if string == "RM" {
                withAnimation {
                    waitingForReceivedConfirmation = false
                }
                
                return
            }
            
            if string.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 {
                readString = string
            }
        }
    }
    
    // Wrote value to a characteristic (a message was sent to the bluetooth device.)
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        if let error {
            print("Error writing value for characteristic. \(error.localizedDescription).\nValue:\n")
            errorDescription = error.localizedDescription
            showAlert = true
            return
        }
        print("Did write value for \(characteristic)")
    }
}

//
//  Bluetooth Scanner.swift
//  Arduino-3D-Scanner
//
//  Created by Leonardo Larrañaga on 4/28/24.
//

import SwiftUI
import CoreBluetooth

struct BluetoothScanner: View {
    
    @ObservedObject var bluetoothManager: BluetoothManager
    
    @State var i = 0
    
    var body: some View {
        VStack {            
            Text("Services")
            List(bluetoothManager.discoveredServices, id: \.uuid) { service in
                Text("\(service)")
            }
                        
            Button("Send to a lot of messages to Arduino") {
                if (bluetoothManager.writableCharacteristic != nil) {
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                        bluetoothManager.send("Sent message # \(i)\n")
                        i += 1
                    }
                }
            }
            
            Text("Characteristics")
            List(bluetoothManager.discoveredCharacteristics, id: \.uuid) { characteristic in
                Text("\(characteristic.uuid)")
            }
        }
        .navigationTitle(bluetoothManager.getName(of: bluetoothManager.connectedPeripheral))
    }
}
 

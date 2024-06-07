//
//  Bluetooth Scanner.swift
//  Arduino-3D-Scanner
//
//  Created by Leonardo Larrañaga on 4/28/24.
//

import SwiftUI
import CoreBluetooth
import SceneKit

struct BluetoothScanner: View {
    
    @ObservedObject var bluetoothManager: BluetoothManager
    @Environment(\.modelContext) var modelContext
    
    @State var scanStarted = false
    @State var scanStopped = false
    
    @State var showFinishAlert = false
    @State var finishedScanning = false
    
    @State var scene = SCNScene()
    
    @State var scanTitle = ""
    @State var pointCloud = ""
    @State var startedTime = Date()
    @State var finishedTime = Date()
    
    @State var receivedMS = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if (scanStarted) {
                    SceneView(scene: scene, options: [.allowsCameraControl, .autoenablesDefaultLighting], preferredFramesPerSecond: 120)
                } else {
                    Button {
                        withAnimation {
                            bluetoothManager.send("START")
                            startedTime = .now
                            scanStarted.toggle()
                        }
                    } label: {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 125))
                    }
                }
            }
            .navigationTitle(bluetoothManager.getName(of: bluetoothManager.connectedPeripheral))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .topTrailing) {
                if scanStarted {
                    Button("", systemImage: scanStopped ? "play.circle.fill" : "stop.circle.fill") {
                        bluetoothManager.send(scanStopped ? "CONTINUE" : "STOP")
                        
                        withAnimation {
                            scanStopped.toggle()
                        }
                    }
                    .font(.system(size: 35))
                    .padding(25)
                }
            }
            .overlay(alignment: .topLeading) {
                if scanStarted {
                    Button("", systemImage: "octagon.fill") {
                        showFinishAlert.toggle()
                    }
                    .foregroundStyle(.red)
                    .font(.system(size: 35))
                    .padding(25)
                }
            }
        }
        .preferredColorScheme(scanStarted ? .dark : .light)
        .task { scene.background.contents = UIColor.black }
        .alert("Finish Scan", isPresented: $showFinishAlert) {
            Button("Finish", role: .destructive) {
                finishedScanning.toggle()
                finishedTime = .now
            }
            
            Button("Cancel", role: .cancel) {}
        }
        .alert("Finish Scan", isPresented: $finishedScanning) {
            TextField("Scan title...", text: $scanTitle)
                .foregroundStyle(.black)
                .multilineTextAlignment(.center)
                .bold()
            
            Button("Save") {
                scanStarted = false
                
                bluetoothManager.send("END")
                
                let title = scanTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Untitled Scan" : scanTitle
                
                let scan = Scan(title: title, startTime: startedTime, endTime: .now, pointCloud: pointCloud)
                
                modelContext.insert(scan)
                try? modelContext.save()
                
                bluetoothManager.disconnectPeripheral()
            }
            .tint(.blue)
            
            Button("Delete") {
                bluetoothManager.send("END")
                bluetoothManager.disconnectPeripheral()
            }
        }
        .task {
            let cameraNode = SCNNode()
            cameraNode.camera = SCNCamera()
            cameraNode.position = SCNVector3Make(0, 0, 20)
            scene.rootNode.addChildNode(cameraNode)
        }
        .onChange(of: bluetoothManager.readString) { oldValue, newValue in
            if newValue == "END" {
                finishedScanning.toggle()
                finishedTime = .now
                return
            }
            
            if newValue.hasPrefix("MS") {
                receivedMS = true
                return
            }
            
            if receivedMS {
                // Received the rest of the numbers...
                if newValue.trimmingCharacters(in: .decimalDigits).trimmingCharacters(in: .punctuationCharacters).count == 0 {
                    
                    let message = oldValue + newValue
                    print("Complete coordinate:", message)
                    
                    var components = message.components(separatedBy: .whitespaces)
                    components = Array(components.dropFirst())
                    
                    if components.count >= 3 {
                        if let x = Double(components[0]), let y = Double(components[1]), let z = Double(components[2]) {
                            
                            pointCloud.append(String(format: "%.4f %.4f %.4f\n", x, y, z))
                            
                            let point = SCNVector3(x, y, z)
                            
                            let sphere = SCNSphere(radius: 0.01)
                            
                            let sphereNode = SCNNode(geometry: sphere)
                            sphereNode.position = point
                            
                            scene.rootNode.addChildNode(sphereNode)
                        }
                    }
                }
            }
        }
    }
}


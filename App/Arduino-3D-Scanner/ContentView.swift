//
//  ContentView.swift
//  Arduino-3D-Scanner
//
//  Created by Leonardo Larrañaga on 4/26/24.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State var showingScanView = false
    @State var flag = false
    @State var example = ""
    
    @StateObject var bluetoothManager = BluetoothManager()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Spacer()
                    
                    (horizontalSizeClass == .compact ? AnyLayout(VStackLayout()) : AnyLayout(HStackLayout())) {
                        VStack {
                            BluetoothButton
                            SimulateMenu
                        }
                        
                        if bluetoothManager.discoveredPeripherals.count > 0 {
                            VStack {
                                Text("Connect with Scanner using Bluetooth")
                                    .font(.title3.bold())
                                    .fontWeight(.bold)
                                
                                List(bluetoothManager.discoveredPeripherals, id: \.identifier) { peripheral in
                                    Button {
                                        bluetoothManager.connect(to: peripheral)
                                    } label: {
                                        Text(bluetoothManager.getName(of: peripheral))
                                    }
                                }
                                .scrollContentBackground(.hidden)
                                .frame(height: 600)
                            }
                        }
                    }
                    
                    
                    Spacer()
                    
                    
                    Text("Project by:\nLarrañaga Flores Luis Leonardo\nPerez Solorio Kadir Josafat")
                        .font(.caption)
                        .fontDesign(.monospaced)
                        .foregroundStyle(.secondary.opacity(0.8))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
            }
            .scrollContentBackground(.hidden)
            .scrollDisabled(horizontalSizeClass == .regular)
            .background(Color(uiColor: colorScheme == .light ? .systemGroupedBackground : .black))
            .navigationTitle("3D-Scanner")
            .onChange(of: flag) {
                showingScanView.toggle()
            }
            .fullScreenCover(isPresented: .constant(bluetoothManager.connectedPeripheral != nil)) {
                BluetoothScanner(bluetoothManager: bluetoothManager)
            }
            .fullScreenCover(isPresented: $showingScanView) {
                NavigationStack {
                    ScannerSimulation(example: example)
                }
            }
            .alert(bluetoothManager.errorDescription, isPresented: $bluetoothManager.showAlert) {}
            .task {
                UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = .red
            }
        }
    }
    
    var SimulateMenu: some View {
        Menu("Simulate Scan") {
            Button("Cat", systemImage: "cat.fill") {
                example = "Cat"
                flag.toggle()
            }
            
            Button("Spiral", systemImage: "lasso") {
                example = "Spiral"
                flag.toggle()
            }
        }
        .font(.title3.bold())
    }
    
    var BluetoothButton: some View {
        ZStack {
            Circle()
                .fill(.blue.opacity(bluetoothManager.bluetoothAnimation ? 0.5 : 0))
                .frame(width: 375, height: 375)
                .scaleEffect(bluetoothManager.bluetoothAnimation ? 1 : 0)
            
            Circle()
                .fill(.blue.opacity(bluetoothManager.bluetoothAnimation ? 0.4 : 0))
                .frame(width: 275, height: 275)
                .scaleEffect(bluetoothManager.bluetoothAnimation ? 1 : 0)
            
            Circle()
                .fill(.blue.opacity(bluetoothManager.bluetoothAnimation ? 0.3 : 0))
                .frame(width: 175, height: 175)
                .scaleEffect(bluetoothManager.bluetoothAnimation ? 1 : 0)
            
            Button {
                bluetoothManager.bluetoothAnimation.toggle()
                
                if bluetoothManager.isDiscoveringPeripherals {
                    bluetoothManager.stopScan()
                } else {
                    bluetoothManager.startScan()
                }
            } label: {
                Image("Bluetooth")
                    .font(.system(size: 95))
                    .padding(35)
                    .background()
                    .clipShape(.circle)
            }
        }
        .frame(width: 400, height: bluetoothManager.bluetoothAnimation ? 400 : 200)
        .offset(x: bluetoothManager.bluetoothAnimation && bluetoothManager.discoveredPeripherals.count > 0 ? 10 : 0)
        .animation(.bouncy(duration: 1.0).repeatForever(autoreverses: true), value: bluetoothManager.bluetoothAnimation)
    }
}

#Preview {
    ContentView()
}

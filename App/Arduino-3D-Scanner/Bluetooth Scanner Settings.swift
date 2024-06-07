//
//  Bluetooth Scanner Settings.swift
//  ARDSCAN
//
//  Created by Leonardo Larrañaga on 5/28/24.
//

import SwiftUI

struct BluetoothScannerSettings: View {
    
    @ObservedObject var bluetoothManager: BluetoothManager
    @State var next = false
    @State var heightDifference = 5.0
    @State var isCm = false
    @State var scanning = false
    
    var doubleFormatter: NumberFormatter = {
       let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.roundingMode = .down
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    var body: some View {
        VStack {
            Text("Points per revolution")
                .font(.largeTitle.bold())
            
            HStack(spacing: 20) {
                OctagonSpeed(speed: 200, description: "Fastest, less accurate.")
                    .padding(.leading, 35)
                OctagonSpeed(speed: 200 * 2, description: "Faster, less accurate.")
                OctagonSpeed(speed: 200 * 4, description: "Moderate speed, accurate.")
            }
            .frame(height: 350)
            
            
            HStack(spacing: 20) {
                OctagonSpeed(speed: 200 * 8, description: "Slower, more accurate.")
                OctagonSpeed(speed: 200 * 16, description: "Slower, very accurate.")
                OctagonSpeed(speed: 200 * 32, description: "Slowest, most accurate.")
            }
            .frame(height: 350)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .confirmationProgress(bluetoothManager: bluetoothManager)
        .fullScreenCover(isPresented: $next) {
            VStack {
                Text("Height difference per revolution")
                    .font(.largeTitle.bold())
                
                HStack {
                    TextField("Height Difference", value: $heightDifference, formatter: doubleFormatter)
                        .padding()
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 150)
                        .padding(.trailing, 15)
                    
                    Picker("", selection: $isCm) {
                        Text("mm")
                            .tag(false)
                        Text("cm")
                            .tag(true)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 150)
                }
                
                Button("Continue") {
                    let string: Double = isCm ? heightDifference : heightDifference / 10.0
                    
                    bluetoothManager.send(string.description)
                    
                    scanning.toggle()
                }
                .tint(.white)
                .font(.title2.bold())
                .padding(.horizontal, 40)
                .padding(.vertical, 10)
                .background(.blue)
                .clipShape(.rect(cornerRadius: 12))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .confirmationProgress(bluetoothManager: bluetoothManager)
            .fullScreenCover(isPresented: $scanning) {
                BluetoothScanner(bluetoothManager: bluetoothManager)
            }
            .onChange(of: isCm) { _, newValue in
                if newValue {
                    heightDifference /= 10
                } else {
                    heightDifference *= 10
                }
            }
        }
        
    }
    
    @ViewBuilder
    func OctagonSpeed(speed: Int, description: String) -> some View {
        Button {
            bluetoothManager.send(speed.description)
            next.toggle()
        } label: {
            VStack {
                SpinningOctagon(speed: speed)
                    .frame(width: 250, height: 250)
                Text("\(speed) points per revolution")
                    .bold()
                Text(description)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.blue, lineWidth: 2.0)
            }
        }
    }
}

struct SpinningOctagon: View {
    let speed: Int
    @State private var rotation: Double = 0
    
    var body: some View {
        OctagonalBase(holeRatio: 4)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(Animation.linear(duration: Double(speed) / 100).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
    }
}

#Preview {
    BluetoothScannerSettings(bluetoothManager: BluetoothManager())
}

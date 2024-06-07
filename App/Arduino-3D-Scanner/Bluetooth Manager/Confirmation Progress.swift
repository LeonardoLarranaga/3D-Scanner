//
//  Confirmation Progress.swift
//  ARDSCAN
//
//  Created by Leonardo Larrañaga on 5/28/24.
//

import SwiftUI

struct ConfirmationProgress: ViewModifier {
    @ObservedObject var bluetoothManager: BluetoothManager
    func body(content: Content) -> some View {
        content
            .overlay {
                if bluetoothManager.waitingForReceivedConfirmation {
                    ProgressView()
                        .controlSize(.extraLarge)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.ultraThinMaterial)
                        .ignoresSafeArea()
                }
            }
    }
}

extension View {
    func confirmationProgress(bluetoothManager: BluetoothManager) -> some View {
        modifier(ConfirmationProgress(bluetoothManager: bluetoothManager    ))
    }
}

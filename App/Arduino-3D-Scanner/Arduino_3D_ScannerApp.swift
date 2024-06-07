//
//  Arduino_3D_ScannerApp.swift
//  Arduino-3D-Scanner
//
//  Created by Leonardo Larrañaga on 4/24/24.
//

import SwiftUI
import SwiftData

@main
struct Arduino_3D_ScannerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Scan.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                
                Recents()
                    .tabItem {
                        Label("Recents", systemImage: "arrow.counterclockwise.circle")
                    }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}

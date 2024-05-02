//
//  ScannerView.swift
//  Arduino-3D-Scanner
//
//  Created by Leonardo Larrañaga on 4/26/24.
//

import SwiftUI
import SceneKit

struct ScannerSimulation: View {
    
    let example: String
    
    @Environment(\.dismiss) var dismiss
    
    @State var scene = SCNScene()
    @State var scanning = false
    
    @State var finishSimulation = false
    @State var index = 0
    @State var speed = 2.5
    @State var dismissed = false
    
    @State var pointCloud: [SCNVector3]? = nil
    
    var body: some View {
        VStack {
            if scanning == false {
                Button("Start Scan") {
                    Task { await createScene() }
                    
                    withAnimation {
                        scanning = true
                    }
                }
            } else {
                SceneView(scene: scene, options: [.autoenablesDefaultLighting, .allowsCameraControl], preferredFramesPerSecond: 60)
                    .ignoresSafeArea()
                    .overlay(alignment: .topTrailing) {
                        Button("Finish Simulation") {
                            finishSimulation = true
                            drawRestOfFigure()
                        }
                    }
                
                Slider(value: $speed, in: 0...2.5) {
                } minimumValueLabel: {
                    Image(systemName: "hare.fill")
                } maximumValueLabel: {
                    Image(systemName: "tortoise.fill")
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .topLeading) {
            Button {
                dismissed = true
            } label: {
                Image(systemName: "xmark")
                    .font(.title2)
                    .padding(10)
                    .background(.thinMaterial)
                    .clipShape(.rect(cornerRadius: 12))
                    .padding()
            }
            .tint(.primary)
        }
        .navigationTitle("Scan Simulation: \(example)")
        .preferredColorScheme(scanning ? .dark : .light)
    }
    
    func createScene() async {
        scene.background.contents = UIColor.black
        
        let cameraNode = await SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3Make(0, 0, 100)
        await scene.rootNode.addChildNode(cameraNode)
        
        pointCloud = PointCloud.loadPointCloud(from: example)
        
        if let pointCloud {
            for index in 0..<pointCloud.count {
                if finishSimulation { return }
                try? await Task.sleep(nanoseconds: UInt64(speed * 1_000_000_000))
                print(speed)
                let sphere = SCNSphere(radius: 0.1)
                let sphereNode = await SCNNode(geometry: sphere)
                sphereNode.position = pointCloud[index]
                
                await scene.rootNode.addChildNode(sphereNode)
            }
        } else {
            dismissView()
        }
    }
    
    func drawRestOfFigure() {
        for index in index..<pointCloud!.count {
            let sphere = SCNSphere(radius: 0.1)
            let sphereNode = SCNNode(geometry: sphere)
            sphereNode.position = pointCloud![index]
            
            scene.rootNode.addChildNode(sphereNode)
        }
    }
    
    func dismissView() {
        pointCloud = []
        scene = SCNScene()
        
    }
}

#Preview {
    ScannerSimulation(example: "Cat")
}

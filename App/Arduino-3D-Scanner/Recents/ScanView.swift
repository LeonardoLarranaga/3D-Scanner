//
//  ScanView.swift
//  ARDSCAN
//
//  Created by Leonardo Larrañaga on 6/5/24.
//

import SwiftUI
import SceneKit
import UniformTypeIdentifiers

struct ScanView: View {
    
    @State var scene = SCNScene()
    @State var showingFileTypes = false
    @State var exportingFile = false
    @State var fileType = "txt"
    
    let scan: Scan
    
    var body: some View {
        NavigationStack {
            SceneView(scene: scene, options: [.allowsCameraControl, .autoenablesDefaultLighting], preferredFramesPerSecond: 120)
                .navigationTitle(scan.title)
                .overlay(alignment: .top) {
                    VStack {
                        HStack {
                            Text("Started at \(scan.startTime.formatted)")
                                .padding(.leading)
                            Spacer()
                            Text("Ended at \(scan.endTime.formatted)")
                                .padding(.trailing)
                        }
                        .background(.ultraThinMaterial)
                        
                        Button("", systemImage: "square.and.arrow.down") {
                            withAnimation(.spring) {
                                showingFileTypes.toggle()
                            }
                        }
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding()
                    }
                    
                }
                .overlay {
                    if showingFileTypes {
                        VStack {
                            Text("Pick a file type")
                                .font(.title2.bold())
                            
                            HStack {
                                Button {
                                    fileType = "txt"
                                    exportingFile.toggle()
                                } label: {
                                    Image("TXT Icon")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 250)
                                }
                                
                                Button {
                                    fileType = "xyz"
                                    exportingFile.toggle()
                                } label: {
                                    Image("XYZ Icon")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 250)
                                }
                            }
                            
                            Button("Cancel") {
                                withAnimation(.spring) {
                                    showingFileTypes = false
                                }
                            }
                        }
                        .opacity(showingFileTypes ? 1 : 0)
                        .padding()
                        .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
                        .transition(.push(from: .bottom))
                        .transition(.slide)
                    }
                }
                .fileExporter(isPresented: $exportingFile, document: PointCloudDocument(content: scan.pointCloud), contentType: fileType == "txt" ? .plainText : .xyz, defaultFilename: "\(scan.title).\(fileType)") { _ in
                    withAnimation(.spring) {
                        showingFileTypes = false
                    }
                }
        }
        .preferredColorScheme(.dark)
        .task {
            scene.background.contents = UIColor.black
            
            let cameraNode = SCNNode()
            cameraNode.camera = SCNCamera()
            cameraNode.position = SCNVector3Make(0, 0, 20)
            scene.rootNode.addChildNode(cameraNode)
            
            for line in scan.pointCloud.components(separatedBy: "\n") {
                print(line)
                
                let c = line.components(separatedBy: .whitespaces)
                if (c.count >= 3) {
                    let components = c.prefix(3).map { Double($0)! }
                    let sphere = SCNSphere(radius: 0.01)
                    let sphereNode = SCNNode(geometry: sphere)
                    sphereNode.position = SCNVector3(components[0], components[1], components[2])
                    
                    scene.rootNode.addChildNode(sphereNode)
                }
            }
            
            print(scan.pointCloud)
        }
    }
}

extension UTType {
    static var xyz: UTType {
        UTType(exportedAs: "public.xyz")
    }
}

struct PointCloudDocument: FileDocument {
    static var readableContentTypes: [UTType] {
        [.plainText, .xyz]
    }
    
    var content: String
    
    init(content: String) {
        self.content = content
    }
    
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents,
           let string = String(data: data, encoding: .utf8) {
            content = string
        } else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(content.utf8)
        return FileWrapper(regularFileWithContents: data)
    }
}

struct XYZDocument: FileDocument {
    var content: String
    
    static var readableContentTypes: [UTType] { [UTType(filenameExtension: "xyz")!] }
    
    init(content: String = "") {
        self.content = content
    }
    
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            content = String(decoding: data, as: UTF8.self)
        } else {
            content = ""
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: content.data(using: .utf8)!)
    }
}

extension Date {
    var formatted: String {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMM d, yyyy - HH:mm:ss")
        return dateFormatter.string(from: self)
    }
}

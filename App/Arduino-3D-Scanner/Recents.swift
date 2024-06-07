//
//  Recents.swift
//  Arduino-3D-Scanner
//
//  Created by Leonardo Larrañaga on 5/10/24.
//

import SwiftUI
import SwiftData

struct Recents: View {
    
    @Environment(\.modelContext) var modelContext
    @Query var recents: [Scan]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(recents) { recent in
                    NavigationLink {
                        ScanView(scan: recent)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(recent.title)
                                .font(.title3.bold())
                            
                            HStack {
                                Text("\(recent.startTime.formatted) -> \(recent.startTime.formatted)")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                }
            }
            .navigationTitle("Recent Scans")
        }
    }
    
    
    /*func exportSceneToOBJ(completion: @escaping (URL) -> Void) {
        // Crear una escena y agregar el nodo que deseas exportar
        let scene = SCNScene()
        let node = node
        scene.rootNode.addChildNode(node)
        
        // Definir la URL del archivo de destino
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("exportedScene.obj")
        
        // Exportar la escena a un archivo .obj
        scene.write(to: fileURL, options: nil, delegate: nil) { (totalProgress, error, stop) in
            if let error = error {
                print("Error al exportar la escena: \(error.localizedDescription)")
            } else {
                print("Progreso de exportación: \(totalProgress)")
            }
        }
        
        // Verificar si el archivo se ha creado correctamente
        if FileManager.default.fileExists(atPath: fileURL.path) {
            completion(fileURL)
        } else {
            print("No se pudo crear el archivo")
        }
    }
    
    func generateScene() -> SCNScene {

        let data = Data(bytes: points, count: points.count * MemoryLayout<SCNVector3>.size)
        let source = SCNGeometrySource(data: data, semantic: .vertex, vectorCount: points.count, usesFloatComponents: true, componentsPerVector: 3, bytesPerComponent: MemoryLayout<Float>.size, dataOffset: 0, dataStride: MemoryLayout<SCNVector3>.size)
        
        let indices: [Int32] = Array(0..<Int32(points.count))
        let indexData = Data(bytes: indices, count: indices.count * MemoryLayout<Int32>.size)
        
        let element = SCNGeometryElement(data: indexData, primitiveType: .triangles, primitiveCount: points.count / 3, bytesPerIndex: MemoryLayout<Int32>.size)
        
        let geometry = SCNGeometry(sources: [source], elements: [element])
        let node = SCNNode(geometry: geometry)
        self.node = node
        
        let scene = SCNScene()
        scene.rootNode.addChildNode(node)
        
        return scene
    }
    */
    
}

/*struct SceneDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.fileURL] }
    var url: URL?
    
    init(url: URL?) {
        self.url = url
    }
    
    init(configuration: ReadConfiguration) throws {
        
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        guard let url = url else {
            throw CocoaError(.fileNoSuchFile)
        }
        
        return try FileWrapper(url: url)
    }
}*/

#Preview {
    Recents()
}

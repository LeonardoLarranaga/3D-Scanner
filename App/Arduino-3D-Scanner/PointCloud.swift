//
//  PointCloud.swift
//  Arduino-3D-Scanner
//
//  Created by Leonardo Larrañaga on 4/26/24.
//

import SceneKit

class PointCloud {
    static func loadPointCloud(from filename: String) -> [SCNVector3]? {
        guard let fileURL = Bundle.main.url(forResource: "\(filename).txt", withExtension: nil), let content = try? String(contentsOf: fileURL) else { return nil }
        
        var pointCloud = [SCNVector3]()
        
        let lines = content.components(separatedBy: .newlines)
        for line in lines {
            let values = line.components(separatedBy: .whitespaces)
            
            if values.count >= 3,
               let x = Float(values[0]),
               let y = Float(values[1]),
               let z = Float(values[2]) {
                
                let point = SCNVector3(x, y, z)
                pointCloud.append(point)
            }
        }
        
        return pointCloud
    }
}

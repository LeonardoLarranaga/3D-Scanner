import SceneKit
import UIKit

// Your array of SCNVector3 points
let points: [SCNVector3] = [
    SCNVector3(1, 1, 1),
    SCNVector3(2, 2, 2),
    SCNVector3(3, 3, 3)
]

// Create a SceneKit scene
let scene = SCNScene()

// Create a container node to hold all the objects
let containerNode = SCNNode()

// Create a material for the objects
let material = SCNMaterial()
material.diffuse.contents = UIColor.blue // Color for the objects

// Create a sphere to represent each point
let sphereRadius: CGFloat = 0.1 // Adjust the size of the spheres as needed

for point in points {
    let sphereGeometry = SCNSphere(radius: sphereRadius)
    sphereGeometry.materials = [material]

    let sphereNode = SCNNode(geometry: sphereGeometry)
    sphereNode.position = point

    containerNode.addChildNode(sphereNode)
}

// Create lines to connect the points
for i in 0..<points.count {
    for j in i+1..<points.count {
        let startPoint = points[i]
        let endPoint = points[j]

        let lineGeometry = SCNGeometry.line(from: startPoint, to: endPoint)
        let lineNode = SCNNode(geometry: lineGeometry)
        containerNode.addChildNode(lineNode)
    }
}

scene.rootNode.addChildNode(containerNode)

// Extension to create a line geometry between two points
extension SCNGeometry {
    class func line(from startPoint: SCNVector3, to endPoint: SCNVector3) -> SCNGeometry {
        let indices: [Int32] = [0, 1]
        let source = SCNGeometrySource(vertices: [startPoint, endPoint])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        return SCNGeometry(sources: [source], elements: [element])
    }
}

// Present the scene
let sceneView = SCNView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
sceneView.scene = scene

// Present the view
// Present the view
if let liveView = PlaygroundPage.current.liveView as? PlaygroundRemoteLiveViewProxy {
    liveView.send(sceneView)
} else {
    PlaygroundPage.current.liveView = sceneView
}

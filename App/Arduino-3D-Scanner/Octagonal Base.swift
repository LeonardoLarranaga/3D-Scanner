//
//  Test.swift
//  ARDSCAN
//
//  Created by Leonardo Larrañaga on 5/28/24.
//

import SwiftUI

struct Octagon: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            let center = CGPoint(x: rect.midX, y: rect.midY)
            let radius = min(rect.width, rect.height) / 2 * 0.8
            
            for i in 0..<8 {
                let angle = Double(i) * .pi / 4
                let x = center.x + radius * cos(angle)
                let y = center.y + radius * sin(angle)
                
                if i == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            
            path.closeSubpath()
        }
    }
}

#Preview {
    Octagon()
        .fill(Color.blue)
        .padding()
    
}

struct OctagonalBase: View {
    let holeRatio: CGFloat
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Octagon()
                    .stroke(.blue, lineWidth: 25)
                    .fill(.blue.gradient)
                Octagon()
                    .frame(width: geometry.size.width / holeRatio, height: geometry.size.height / holeRatio)
                    .blendMode(.destinationOut)
            }
            .compositingGroup()
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

#Preview {
    OctagonalBase(holeRatio: 4)
}

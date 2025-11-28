//
//  TwoPointsShape.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 11/27/25.
//
import Foundation
import CoreGraphics

public struct ShapeWithTwoPoints: Codable, Equatable {
    var a: CGPoint
    var b: CGPoint 
    
    var strokeWidth: CGFloat
    
    public init(a: CGPoint, b: CGPoint, strokeWidth: CGFloat) {
        self.a = a
        self.b = b
        self.strokeWidth = strokeWidth
    }
    
    public mutating func setBPoint(b: CGPoint) {
        self.b = b
    }
    
    public var rect: CGRect {
        let x1 = min(a.x, b.x)
        let y1 = min(a.y, b.y)
        let x2 = max(a.x, b.x)
        let y2 = max(a.y, b.y)
        return CGRect(x: x1, y: y1, width: x2 - x1, height: y2 - y1)
    }
    
    public var squareRect: CGRect {
        let width = min(abs(b.x - a.x), abs(b.y - a.y))
        let x = b.x < a.x ? a.x - width : a.x
        let y = b.y < a.y ? a.y - width : a.y
        return CGRect(x: x, y: y, width: width, height: width)
    }
    
    
    public var boundingRect: CGRect {
        return rect.insetBy(dx: -strokeWidth/2, dy: -strokeWidth/2)
    }
}

open class TwoPointsShape: Shape {
    open var id: String = UUID().uuidString
    open var point: ShapeWithTwoPoints = ShapeWithTwoPoints(a: .zero, b:.zero, strokeWidth: 1)
    open var type: String = "TwoPointsShape"
    
    init() {}
    
    open func render(in context: CGContext) {
        //
    }
    
    open func hitTest(point: CGPoint) -> Bool {
        return false
    }
    
    
}

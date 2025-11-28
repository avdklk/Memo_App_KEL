//
//  DrawingToolForShapeWithTwoPoints.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 11/27/25.
//
import Foundation
import CoreGraphics

open class DrawingToolForShapeWithTwoPoints: DrawingTool {
//    public typealias ShapeType = Shape & ShapeWithTwoPoints
    
    open var name: String { fatalError("Override me") }
    
    public var shapeInProgress: TwoPointsShape?
    
    public init() { }
    
    open func makeShape() -> TwoPointsShape {
      fatalError("Override me")
    }
    
    public func handleTap(point: CGPoint) {
        
    }
    
    public func handleDragStart(point: CGPoint, colorHex: String) -> any Shape {
        shapeInProgress = makeShape()
        shapeInProgress?.point = ShapeWithTwoPoints(a: point, b: point, strokeWidth: 1)
        
        return shapeInProgress!
    }
    
    public func handleDragContinue(point: CGPoint, velocity: CGPoint) -> Shape? {
        shapeInProgress?.point.setBPoint(b: point)
        return shapeInProgress
    }
    
    public func handleDragEnd(point: CGPoint) {
        guard var shape = shapeInProgress else { return }
        shape.point.setBPoint(b: point)
        shapeInProgress = nil
    }
    
    public func handleDragCancel(point: CGPoint) {
        handleDragEnd(point: point)
    }
    
    public func renderShapeInProgress(transientContext: CGContext) {
      shapeInProgress?.render(in: transientContext)
    }
}

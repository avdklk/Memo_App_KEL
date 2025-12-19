//
//  DrawingToolForShapeWithTwoPoints.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 11/27/25.
//
import Foundation
import CoreGraphics

open class DrawingToolForShapeWithTwoPoints: DrawingTool {
    
    public typealias ShapeType = Shape & ShapeWithTwoPoints
    
    open var name: String { fatalError("Override me") }
    
    public var shapeInProgress: Shape?
    
    public init() { }
    
    open func makeShape() -> Shape {
      fatalError("Override me")
    }
    
    public func handleTap(shapeManager: ShapeManager, point: CGPoint) {
        
    }
    
    public func handleDragStart(shapeManager: ShapeManager, point: CGPoint) {
        shapeInProgress = makeShape()
        if var shapeInTwoPoints = shapeInProgress as? ShapeType {
            shapeInTwoPoints.a = point
            shapeInTwoPoints.b = point
            shapeInTwoPoints.apply(userSettings: shapeManager.userSettings)
        }
        
    }
    
    public func handleDragContinue(shapeManager: ShapeManager, point: CGPoint, velocity: CGPoint) {
        if var shapeInTwoPoints = shapeInProgress as? ShapeType {
            shapeInTwoPoints.b = point
            
            
            if let _ = shapeManager.shapes.popLast() {
                shapeManager.addShape(shape: shapeInTwoPoints)
            }
        }
    }
    
    public func handleDragEnd(shapeManager: ShapeManager, point: CGPoint) {
        if var shapeInTwoPoints = shapeInProgress as? ShapeType {
            shapeInTwoPoints.b = point
            shapeManager.operationStack.apply(operation: AddShapeOperation(shape: shapeInTwoPoints))
        }
    }
    
    public func handleDragCancel(shapeManager: ShapeManager, point: CGPoint) {
        handleDragEnd(shapeManager: shapeManager, point: point)
    }
    
    public func renderShapeInProgress(transientContext: CGContext) {
      shapeInProgress?.render(in: transientContext)
    }
    
    public func apply(shapeManager: ShapeManager, userSettings: UserSettings) {
        shapeInProgress?.apply(userSettings: userSettings)
    }
}

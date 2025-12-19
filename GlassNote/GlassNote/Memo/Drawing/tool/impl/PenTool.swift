//
//  PenTool.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 11/25/25.
//
import UIKit

class PenTool: DrawingTool {
    var name: String = "Pen"
    public var shapeInProgress: PenShape?
    public var velocityBasedWidth: Bool = false
    public var isEraser = false
    private var shapeInProgressBuffer: UIImage?
    private var drawingSize: CGSize = .zero
    private var alpha: CGFloat = 0
    private var lastVelocity: CGPoint = .zero
    public init() { }
    
    func handleTap(shapeManager: ShapeManager, point: CGPoint) {
        //
    }
    
    func handleDragContinue(shapeManager: ShapeManager, point: CGPoint, velocity: CGPoint) {
        guard let shape = shapeInProgress else { return }
        let lastPoint = shape.segments.last?.b ?? shape.start
        
        if lastPoint != point {
          shape.add(segment: PenLineSegment(a: lastPoint, b: point, width: 10))
        }
        if let lastShape = shapeManager.shapes.popLast() {
            shapeManager.addShape(shape: shape)
        }
    }
    
    func handleDragEnd(shapeManager: ShapeManager, point: CGPoint) {
        guard let shapeInProgress = shapeInProgress else { return }
        shapeInProgress.isFinished = true
    }
    
    func handleDragCancel(shapeManager: ShapeManager, point: CGPoint) {
        handleDragEnd(shapeManager: shapeManager, point: point)
    }
    
    func handleDragStart(shapeManager: ShapeManager, point: CGPoint) {
        drawingSize = shapeManager.size
        lastVelocity = .zero
        let shape = PenShape()
        shapeInProgress = shape
        shape.start = point
        shape.add(segment: PenLineSegment(a: point, b: point, width: 10))
        shape.isFinished = false
        shape.apply(userSettings: shapeManager.userSettings)
        shape.isEraser = isEraser
        //        shape.strokeColor = shape.strokeColor.withAlphaComponent(1)
        shapeManager.addShape(shape: shape)
    }
    
    func setEraserMode(isEraser: Bool) {
        self.isEraser = isEraser
    }
}

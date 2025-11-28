//
//  PenTool.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 11/25/25.
//
import UIKit

final class PenTool: DrawingTool {
    
    var name: String { return "Pen" }
    public var shapeInProgress: PenShape?
    public var velocityBasedWidth: Bool = false
    private var shapeInProgressBuffer: UIImage?
    private var drawingSize: CGSize = .zero
    private var alpha: CGFloat = 0

    public init() { }
    
    func setSize(size: CGSize) {
        self.drawingSize = size
    }
    
    func handleTap(point: CGPoint) {
        //
    }
    
    func handleDragStart(point: CGPoint, colorHex: String) -> Shape {
        let shape = PenShape()
        shapeInProgress = shape
        shape.start = point
        shape.isFinished = false
        shape.strokeColor = colorHex
        return shape
    }
    
    func handleDragContinue(point: CGPoint, velocity: CGPoint) {
        guard let shape = shapeInProgress else { return }
        let lastPoint = shape.segments.last?.b ?? shape.start
        
        if lastPoint != point {
          shape.add(segment: PenLineSegment(a: lastPoint, b: point, width: 1))
        }
    }
    
    func handleDragEnd(point: CGPoint) {
        guard let shapeInProgress = shapeInProgress else { return }
        shapeInProgress.isFinished = true
    }
    
    func handleDragCancel(point: CGPoint) {
        handleDragEnd(point: point)
    }
    
    
}

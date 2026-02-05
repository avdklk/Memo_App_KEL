//
//  SelectionTool.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 1/17/26.
//
import UIKit

public class SelectionTool: DrawingTool {
    public let name = "Selection"
    
    private var selectedShape: ShapeSelectable?
    public var isProgressive: Bool { return false }
    private var originalTransform: ShapeTransform?
    private var startPoint: CGPoint?
    private var isDraggingShape = false
    private var isUpdatingSelection = false
    
    public func handleTap(shapeManager: ShapeManager, point: CGPoint) {
//        guard let touchedShape = shapeManager.shapes.compactMap ({ $0 as? ShapeSelectable })
//            .filter({ $0.hitTest(point: point)}).last else { return }
//        shapeManager.updateShape(shape: touchedShape)
//        selectedShape = touchedShape
    }
    
    public func handleDragStart(shapeManager: ShapeManager, point: CGPoint) {
        guard let touchedShape = shapeManager.shapes.compactMap ({ $0 as? ShapeSelectable })
            .filter({ $0.hitTest(point: point)}).last else { return }
        
        selectedShape = touchedShape
        shapeManager.updateShape(shape: touchedShape)
        
        isDraggingShape = true
        originalTransform = touchedShape.transform
        startPoint = point
    }
    
    public func handleDragContinue(shapeManager: ShapeManager, point: CGPoint, velocity: CGPoint) {
        guard
          isDraggingShape,
          let originalTransform = originalTransform,
          let selectedShape = selectedShape,
          let startPoint = startPoint else
        {
          isDraggingShape = false
          return
        }
        let delta = CGPoint(x: point.x - startPoint.x, y: point.y - startPoint.y)
        selectedShape.transform = originalTransform.translated(by: delta)
        
        if let _ = shapeManager.shapes.popLast() {
            shapeManager.addShape(shape: selectedShape)
        }
    }
    
    public func handleDragEnd(shapeManager: ShapeManager, point: CGPoint) {
        guard
          isDraggingShape,
          let originalTransform = originalTransform,
          let selectedShape = selectedShape,
          let startPoint = startPoint else
        {
          isDraggingShape = false
          return
        }
        isDraggingShape = false
    }
    
    public func handleDragCancel(shapeManager: ShapeManager, point: CGPoint) {
        guard isDraggingShape else { return }
        selectedShape?.transform = originalTransform ?? .identity
    }
    
}

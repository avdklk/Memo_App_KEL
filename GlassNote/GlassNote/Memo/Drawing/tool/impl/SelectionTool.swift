//
//  SelectionTool.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 12/3/25.
//

import UIKit

public protocol SelectionToolDelegate: AnyObject {
    /// User tapped on a shape, but it was already selected. You might want to
    /// take this opportuny to activate a tool that can edit that shape, if one
    /// exists.
    func selectionToolDidTapOnAlreadySelectedShape(_ shape: ShapeSelectable)
}

public class SelectionTool: DrawingTool {
    public let name = "Selection"
    
    public var isProgressive: Bool { return false }
    
    /// You may set yourself as the delegate to be notified when special selection
    /// events happen that you might want to react to. The core framework does
    /// not use this delegate.
    public weak var delegate: SelectionToolDelegate?
    
    private var originalTransform: ShapeTransform?
    private var startPoint: CGPoint?
    /* When you tap away from a shape you've just dragged, the method calls look
     like this:
     - handleDragStart (hitTest on selectedShape fails)
     - handleDragContinue
     - handleDragCancel
     - handleTap
     
     We need to be careful not to incorrectly reset the transform for the selected
     shape when you tap away, so we explicitly capture whether you are actually
     dragging the shape or not.
     */
    private var isDraggingShape = false
    
    private var isUpdatingSelection = false
    
    public init(delegate: SelectionToolDelegate? = nil) {
        self.delegate = delegate
    }
    
    public func deactivate(shapeManager: ShapeManager) {
        shapeManager.toolSettings.selectedShape = nil
    }
    
    public func apply(shapeManager: ShapeManager, userSettings: UserSettings) {
        if let shape = shapeManager.toolSettings.selectedShape {
            if isUpdatingSelection {
                if let shapeWithStandardState = shape as? ShapeWithStandardState {
                    shapeManager.userSettings.fillColor = shapeWithStandardState.fillColor
                    shapeManager.userSettings.strokeColor = shapeWithStandardState.strokeColor
                    shapeManager.userSettings.strokeWidth = shapeWithStandardState.strokeWidth
                } else if let shapeWithStrokeState = shape as? ShapeWithStrokeState {
                    shapeManager.userSettings.strokeColor = shapeWithStrokeState.strokeColor
                    shapeManager.userSettings.strokeWidth = shapeWithStrokeState.strokeWidth
                }
            } else {
                shape.apply(userSettings: userSettings)
                shapeManager.toolSettings.isPersistentBufferDirty = true
            }
        }
    }
    
    public func handleTap(shapeManager: ShapeManager, point: CGPoint) {
        if let selectedShape = shapeManager.toolSettings.selectedShape, selectedShape.hitTest(point: point) == true {
//            shapeManager.set(tool: <#T##any DrawingTool#>, shape: <#T##(any Shape)?#>)
        }
        
        updateSelection(shapeManager: shapeManager, shapeManager.drawing.shapes
            .compactMap({ $0 as? ShapeSelectable })
            .filter({ $0.hitTest(point: point) })
            .last)
    }
    
    public func handleDragStart(shapeManager: ShapeManager, point: CGPoint) {
        guard let selectedShape = shapeManager.toolSettings.selectedShape, selectedShape.hitTest(point: point) else {
            isDraggingShape = false
            return
        }
        isDraggingShape = true
        originalTransform = selectedShape.transform
        startPoint = point
    }
    
    public func handleDragContinue(shapeManager: ShapeManager, point: CGPoint, velocity: CGPoint) {
        guard
            isDraggingShape,
            let originalTransform = originalTransform,
            let selectedShape = shapeManager.toolSettings.selectedShape,
            let startPoint = startPoint else
        {
            isDraggingShape = false
            return
        }
        let delta = CGPoint(x: point.x - startPoint.x, y: point.y - startPoint.y)
        selectedShape.transform = originalTransform.translated(by: delta)
        shapeManager.toolSettings.isPersistentBufferDirty = true
    }
    
    public func handleDragEnd(shapeManager: ShapeManager, point: CGPoint) {
        guard
            isDraggingShape,
            let originalTransform = originalTransform,
            let selectedShape = shapeManager.toolSettings.selectedShape,
            let startPoint = startPoint else
        {
            isDraggingShape = false
            return
        }
        let delta = CGPoint(x: point.x - startPoint.x, y: point.y - startPoint.y)
        //      shapeManager.operationStack.apply(operation: ChangeTransformOperation(
        //      shape: selectedShape,
        //      transform: originalTransform.translated(by: delta),
        //      originalTransform: originalTransform))
        shapeManager.toolSettings.isPersistentBufferDirty = true
        isDraggingShape = false
    }
    
    public func handleDragCancel(shapeManager: ShapeManager, point: CGPoint) {
        guard isDraggingShape else { return }
        shapeManager.toolSettings.selectedShape?.transform = originalTransform ?? .identity
        shapeManager.toolSettings.isPersistentBufferDirty = true
    }
    
    /// Update selection on context.toolSettings, but make sure that when apply()
    /// is called as a part of that change, we don't immediately change the
    /// properties of the newly selected shape.
    private func updateSelection(shapeManager: ShapeManager, _ newSelectedShape: ShapeSelectable?) {
        isUpdatingSelection = true
        shapeManager.toolSettings.selectedShape = newSelectedShape
        isUpdatingSelection = false
    }
}


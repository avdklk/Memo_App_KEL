//
//  UndoRedoManager.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 12/14/25.
//

public class UndoRedoManager {
    private var redoStack = [Shape]()
    private weak var shapeManager: ShapeManager?
    
    init(shapeManager: ShapeManager) {
        self.shapeManager = shapeManager
    }
    
    public func undo() {
        if let lastShape = shapeManager?.popLastShape() {
            redoStack.append(lastShape)
            shapeManager?.canRedo = !redoStack.isEmpty
        }
    }
    
    public func redo() {
        if !redoStack.isEmpty, let redoShape = redoStack.popLast() {
            shapeManager?.addShape(shape: redoShape)
            shapeManager?.canRedo = !redoStack.isEmpty
        }
    }
    
    public func resetRedo() {
        redoStack.removeAll()
        shapeManager?.canRedo = false
    }
}

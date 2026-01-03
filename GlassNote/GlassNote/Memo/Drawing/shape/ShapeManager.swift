//
//  ShapeManager.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 11/24/25.
//

import Foundation
import CoreData

public class ShapeManager: ObservableObject {
    @Published var shapes: [Shape] = []
    @Published var isStart: Bool = true
    @Published  var tool: DrawingTool?
    @Published var canUndo: Bool = false
    @Published var canRedo: Bool = false
    
    private var context: NSManagedObjectContext
    var note: Note

    init(context: NSManagedObjectContext, note: Note) {
        self.context = context
        self.note = note
    }
    
    public var drawing: Drawing = Drawing(size: CGSize(width: 320, height: 320)) {
        didSet {
            tool?.deactivate(shapeManager: self)
            operationStack = DrawingOperationStack(shapeManager: self)
            drawing.size = self.size
            tool?.activate(shapeUpdater: self, shapeManager: self)
            //        applyToolSettingsChanges()
            //          applySelectionViewState()
            rerenderAllShapesInefficiently()
            //        if let tool = tool {
            //          delegate?.drawsanaView(self, didSwitchTo: tool)
            //        }
        }
    }
    
    public lazy var undoRedoManager: UndoRedoManager = UndoRedoManager(shapeManager: self)
    public lazy var operationStack: DrawingOperationStack = {
        return DrawingOperationStack(shapeManager: self)
    }()
    public var userSettings: UserSettings = UserSettings(
        strokeColor: .blue,
        fillColor: .yellow,
        strokeWidth: 10,
        fontName: "Helvetica Neue",
        fontSize: 14)
    
    public var toolSettings: ToolSettings = ToolSettings(
        selectedShape: nil,
        interactiveView: nil,
        isPersistentBufferDirty: false)
    
    public var size: CGSize = .zero
    
    public func setSize(size: CGSize) {
        self.size = size
    }
    
    public func setTool(tool: DrawingTool) {
        self.tool = tool
    }
    
    public func addShape(shape: Shape) {
        shapes.append(shape)
    }
    
    public func updateShape(shape: Shape) -> Shape? {
        let filteredShape = shapes.filter({ $0 === shape })
        return filteredShape.first
    }
    
    public func removeShape(shape: Shape) {
        shapes = shapes.filter({ $0 !== shape })
    }
    
    public func popLastShape() -> Shape? {
        return shapes.popLast()
    }
    
    public func saveNewNoteElement() {
        guard let lastShape = shapes.last, let id = UUID(uuidString: lastShape.id), let type = NoteElementType(rawValue: lastShape.type),  let drawingShape = lastShape.getData().toData() else {return}
        
        _ = note.addDrawingElement(in: context, id: id, data: drawingShape, type: type)
        try? context.save()
    }
    
    public func deleteNewNoteElement() {
        let sortedElements = note.sortedElements
        guard !sortedElements.isEmpty, let lastNoteElement = sortedElements.last else {return}
        
        note.removeFromElements(lastNoteElement)
        try? context.save()
    }
    
    public func set(tool: DrawingTool, shape: Shape? = nil) {
        if let oldTool = self.tool, tool === oldTool {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            if let shape = shape {
                shapes.append(shape)
            }
            self.tool?.deactivate(shapeManager: self)
            self.tool = tool
            tool.activate(shapeUpdater: self, shapeManager: self)
            //          self.applyToolSettingsChanges()
            //          self.delegate?.drawsanaView(self, didSwitchTo: tool)
        }
    }
    
    public func undo() {
        deleteNewNoteElement()
        undoRedoManager.undo()
    }
    
    public func redo() {
        undoRedoManager.redo()
        saveNewNoteElement()
    }
    
    public func drawStart(point: CGPoint) {
        isStart = false
        tool?.handleDragStart(shapeManager: self, point: point)
    }
    
    public func drawContinue(point: CGPoint) {
        tool?.handleDragContinue(shapeManager: self, point: point, velocity: .zero)
    }
    
    public func drawEnd(point: CGPoint) {
        isStart = true
        tool?.handleDragEnd(shapeManager: self, point: point)
        saveNewNoteElement()
        canUndo = !shapes.isEmpty
        undoRedoManager.resetRedo()
    }
    
    public func getShape() {
        let savedShapes = note.shapes
        shapes = savedShapes
        canUndo = !shapes.isEmpty
    }
}

extension ShapeManager: DrawsanaViewShapeUpdating {
    public func rerenderAllShapesInefficiently() {
        //applySelectionViewState
        //transform만 계산 @Pulbished transform
        // DrawView()에서 selectedIndicatorView에 hidden이랑 transform 할당하기
    }
}

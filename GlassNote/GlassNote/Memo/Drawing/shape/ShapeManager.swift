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
    
    public lazy var undoRedoManager: UndoRedoManager = UndoRedoManager(shapeManager: self)
    public var size: CGSize = .zero
    public var userSettings: UserSettings = UserSettings(
        strokeColor: .blue,
        fillColor: .blue,
        strokeWidth: 8,
        fontName: "Helvetica Neue",
        fontSize: 15,
        fontColor: .blue,
        eraserWidth: 15)
    
    public func setSize(size: CGSize) {
        self.size = size
    }
    
    public func setTool(tool: DrawingTool) {
        self.tool = tool
    }
    
    public func addShape(shape: Shape) {
        shapes.append(shape)
    }
    
    public func updateShape(shape: Shape) {
        guard let filterShape = shapes.first(where:{ $0.id == shape.id }) else {return}
        let _ = shapes.removeAll(where:{ $0.id == filterShape.id})
        shapes.append(shape)
    }
    
    public func removeShape(shape: Shape) {
        shapes = shapes.filter({ $0 !== shape })
    }
    
    public func popLastShape() -> Shape? {
        return shapes.popLast()
    }
    
    func updateNoteElementData() {
        guard let lastShape = shapes.last,
              let uuid = UUID(uuidString: lastShape.id),
                let element = note.findElement(id: uuid) else { return }
    
        element.createdAt = Date()
        element.drawingShape = lastShape.getData().toData()
        
        do {
            try context.save()
            print("✅ 업데이트(수정) 완료: \(uuid)")
        } catch {
            print("업데이트 실패: \(error)")
        }
    }
    
    public func saveNewNoteElement() {
        guard let lastShape = shapes.last, !(tool is SelectionTool), let id = UUID(uuidString: lastShape.id), let type = NoteElementType(rawValue: lastShape.type),  let drawingShape = lastShape.getData().toData() else {return}
        
        _ = note.addDrawingElement(in: context, id: id, data: drawingShape, type: type)
        try? context.save()
    }
    
    
    public func deleteNewNoteElement() {
        let sortedElements = note.sortedElements
        guard !sortedElements.isEmpty, let lastNoteElement = sortedElements.last else {return}
        
        note.removeFromElements(lastNoteElement)
        context.delete(lastNoteElement)
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
    
    public func tab(point: CGPoint) {
        tool?.handleTap(shapeManager: self, point: point)
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
        if tool is SelectionTool {
            updateNoteElementData()
        } else {
            saveNewNoteElement()
        }
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

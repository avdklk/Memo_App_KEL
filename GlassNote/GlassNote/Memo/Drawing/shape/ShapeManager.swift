//
//  ShapeManager.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 11/24/25.
//

import Foundation

public class ShapeManager: ObservableObject {
    @Published var shapes: [Shape] = []
    @Published var isStart: Bool = true
    @Published  var tool: DrawingTool?

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

    public init() {}
    
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
        undoRedoManager.undo()
    }
    
    public func redo() {
        undoRedoManager.redo()
    }
    
    public func drawStart(point: CGPoint) {
//        let shape = tool.handleDragStart(point: point, colorHex: "#000000")
//        shapes.append(shape)
        isStart = false
        tool?.handleDragStart(shapeManager: self, point: point)
    }
    
    public func drawContinue(point: CGPoint) {
//        guard let newShape = tool.handleDragContinue(point: point, velocity:.zero) else {return}
//        shapes[shapes.count - 1] = newShape
        
        tool?.handleDragContinue(shapeManager: self, point: point, velocity: .zero)
    }
    
    public func drawEnd(point: CGPoint) {
//        tool.handleDragEnd(point: point)
        isStart = true
        tool?.handleDragEnd(shapeManager: self, point: point)
    }
    
    public func saveShape() {
        let savingManager = SavingManager()
        let drawing = Drawing(shapes: shapes, size: size)
        do {
            try savingManager.save(drawing: drawing)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func getShape() {
        let savingManager = SavingManager()
        
        do {
            let drawing = try savingManager.loadShapes()
            self.shapes = drawing.shapes
            //GlassNote.RectShape
            //는 없음
            self.size = drawing.size
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension ShapeManager: DrawsanaViewShapeUpdating {
    public func rerenderAllShapesInefficiently() {
        //applySelectionViewState
        //transform만 계산 @Pulbished transform
        // DrawView()에서 selectedIndicatorView에 hidden이랑 transform 할당하기
    }
}

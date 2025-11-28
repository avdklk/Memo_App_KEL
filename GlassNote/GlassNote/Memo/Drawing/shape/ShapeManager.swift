//
//  ShapeManager.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 11/24/25.
//

import Foundation

class ShapeManager: ObservableObject {
    @Published var shapes: [Shape] = []
    @Published var isStart: Bool = true
    @Published  var tool: DrawingTool = RectTool()
    public var size: CGSize = .zero
    private var index: Int = 0
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
    
    public func drawStart(point: CGPoint) {
        let shape = tool.handleDragStart(point: point, colorHex: "#000000")
        shapes.append(shape)
        isStart = false
    }
    
    public func drawContinue(point: CGPoint) {
        guard let newShape = tool.handleDragContinue(point: point, velocity:.zero) else {return}
        print("index = \(index)")
        print("shapes[index] = \(shapes[index])")
        shapes[index] = newShape
    }
    
    public func drawEnd(point: CGPoint) {
        tool.handleDragEnd(point: point)
        isStart = true
        index += 1
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

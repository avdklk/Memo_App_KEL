//
//  TransformDrawingTool.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 1/24/26.
//
import Foundation
import CoreGraphics

open class TransformDrawingTool: DrawingTool {
    open var name: String { fatalError("Override me") }
    
    public var shapeInProgress: TransformSelectable?
    private var originalTransform: ShapeTransform?
    private var startPoint: CGPoint?
    
    public init() { }
    
    open func makeShape() -> TransformSelectable? {
        return nil
    }
    
    public func handleTap(shapeManager: ShapeManager, point: CGPoint) {
        
    }
    
    public func handleDragStart(shapeManager: ShapeManager, point: CGPoint) {
         if let touchedShape = shapeManager.shapes.compactMap ({ $0 as? TransformSelectable })
            .filter({ $0.hitTest(point: point)}).last {
             shapeInProgress = touchedShape
             shapeManager.updateShape(shape: touchedShape)
             startPoint = point
             originalTransform = touchedShape.transform
         } else if let shapeInProgress = self.shapeInProgress {
             shapeManager.updateShape(shape: shapeInProgress)
             originalTransform = shapeInProgress.transform
         } else if let newShape = makeShape() {
             newShape.createdAt = Date()
             newShape.transform = newShape.transform.translated(by: point)
             shapeInProgress = newShape
             shapeManager.addShape(shape: newShape)
             startPoint = point
             originalTransform = newShape.transform
         }
        
    }
    
//    public func handleDragContinue(shapeManager: ShapeManager, point: CGPoint, velocity: CGPoint) {
//        guard let shapeInProgress = self.shapeInProgress,
//              let startPoint = self.startPoint,
//              let originalTransform = self.originalTransform else {return}
//        
//        let delta = CGPoint(x: point.x - startPoint.x, y: point.y - startPoint.y)
//        shapeInProgress.transform = originalTransform.translated(by: delta)
//        
//        if let _ = shapeManager.shapes.popLast() {
//            shapeManager.addShape(shape: shapeInProgress)
//        }
//    }
    
    public func handleDragContinue(shapeManager: ShapeManager, point: CGPoint, velocity: CGPoint) {
        guard let shapeInProgress = self.shapeInProgress,
              let startPoint = self.startPoint,
              let originalTransform = self.originalTransform else { return }
        
        // 1. 현재 드래그로 인한 이동 거리(Delta) 계산
        let delta = CGPoint(x: point.x - startPoint.x, y: point.y - startPoint.y)
        
        // 2. '이동했다 치고' 예상되는 새로운 X, Y 좌표 계산 (Proposed Translation)
        var newX = originalTransform.translation.x + delta.x
        var newY = originalTransform.translation.y + delta.y
        
        // 3. 도형의 현재 실제 크기 계산 (스케일 반영)
        // (도형이 커져 있으면 그만큼 벽에 빨리 닿아야 하므로 스케일을 곱해야 함)
        let shapeWidth = shapeInProgress.boundingRect.width * originalTransform.scale
        let shapeHeight = shapeInProgress.boundingRect.height * originalTransform.scale
        
        // 4. 좌표 가두기 (Clamping) 🚧
        
        // 4-1. 왼쪽(minX)과 위쪽(minY) 벽 막기
        // 0보다 작아지려 하면 0으로 고정
        newX = max(newX, 0)
        newY = max(newY, 0)
        
        // 4-2. 오른쪽(maxX)과 아래쪽(maxY) 벽 막기
        // (전체화면너비 - 도형너비)보다 커지려 하면 그 위치에 고정
        newX = min(newX, shapeManager.canvasSize.width - shapeWidth)
        newY = min(newY, shapeManager.canvasSize.height - shapeHeight)
        
        // 5. 보정된 좌표(newX, newY)를 적용
        // 기존의 translated(by:) 대신 직접 값을 할당하는 방식이 더 정확합니다.
        var newTransform = originalTransform
        newTransform.translation = CGPoint(x: newX, y: newY)
        
        shapeInProgress.transform = newTransform
        // 6. 매니저 업데이트
        if let _ = shapeManager.shapes.popLast() {
            shapeManager.addShape(shape: shapeInProgress)
        }
    }
    
    public func handleDragEnd(shapeManager: ShapeManager, point: CGPoint) {
    }
    
    public func handleDragCancel(shapeManager: ShapeManager, point: CGPoint) {
        handleDragEnd(shapeManager: shapeManager, point: point)
    }
    
    public func handleMagnification(shapeManager: ShapeManager, scale: CGFloat) {
        guard let shapeInProgress = self.shapeInProgress,
              let originalTransform = self.originalTransform else {return}
        shapeInProgress.transform = originalTransform.scaled(by: scale)
        if let _ = shapeManager.shapes.popLast() {
            shapeManager.addShape(shape: shapeInProgress)
        }
    }
    
    public func handleRotation(shapeManager: ShapeManager, angle: CGFloat) {
        guard let shapeInProgress = self.shapeInProgress,
              let originalTransform = self.originalTransform else {return}
        
        shapeInProgress.transform = originalTransform.rotated(by: angle)
        if let _ = shapeManager.shapes.popLast() {
            shapeManager.addShape(shape: shapeInProgress)
        }
    }
}

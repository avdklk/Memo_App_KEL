//
//  HandleResizeTool.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 1/26/26.
//

import UIKit

public enum ResizeHandle: Equatable {
    case topLeft, topRight, bottomLeft, bottomRight  // 꼭지점 (비율 유지)
    case top, bottom, left, right                     // 변 (단일 축)
    case move                                         // 이동
    case none
}

public class HandleResizeTool: DrawingTool {
    public let name = "HandleResize"
    
    public var selectedShape: TransformSelectable?
    public var activeHandle: ResizeHandle = .none
    
    private var originalTransform: ShapeTransform?
    private var originalSize: CGSize?
    private var startPoint: CGPoint?
    
    public init() {}
    
    public func handleTap(shapeManager: ShapeManager, point: CGPoint) {
        if let touchedShape = shapeManager.shapes.compactMap({ $0 as? TransformSelectable })
            .filter({ $0.hitTest(point: point) }).last {
            selectedShape = touchedShape
            shapeManager.updateShape(shape: touchedShape)
        } else {
            selectedShape = nil
        }
    }
    
    public func handleDragStart(shapeManager: ShapeManager, point: CGPoint) {
        // 먼저 핸들 영역 체크
        if let shape = selectedShape {
            let handle = hitTestHandle(shape: shape, point: point)
            if handle != .none {
                activeHandle = handle
                startPoint = point
                originalTransform = shape.transform
                originalSize = shape.boundingRect.size
                return
            }
        }
        
        // 핸들이 아니면 새로운 도형 선택 시도
        if let touchedShape = shapeManager.shapes.compactMap({ $0 as? TransformSelectable })
            .filter({ $0.hitTest(point: point) }).last {
            selectedShape = touchedShape
            shapeManager.updateShape(shape: touchedShape)
            activeHandle = .move
            startPoint = point
            originalTransform = touchedShape.transform
            originalSize = touchedShape.boundingRect.size
        } else {
            selectedShape = nil
            activeHandle = .none
        }
    }
    
    public func handleDragContinue(shapeManager: ShapeManager, point: CGPoint, velocity: CGPoint) {
        guard let shape = selectedShape,
              let startPoint = startPoint,
              let originalTransform = originalTransform,
              let originalSize = originalSize else { return }
        
        let delta = CGPoint(x: point.x - startPoint.x, y: point.y - startPoint.y)
        
        switch activeHandle {
        case .move:
            // 이동
            shape.transform = originalTransform.translated(by: delta)
            
        case .topLeft, .topRight, .bottomLeft, .bottomRight:
            // 꼭지점: 비율 유지하며 스케일
            let scaleFactor = calculateCornerScale(handle: activeHandle, delta: delta, originalSize: originalSize)
            shape.transform = originalTransform.scaled(by: scaleFactor)
            
        case .left, .right:
            // 가로만 조정
            if let resizableShape = shape as? ResizableShape {
                let widthDelta = (activeHandle == .right) ? delta.x : -delta.x
                let newWidth = max(50, originalSize.width + widthDelta)
                resizableShape.customSize = CGSize(width: newWidth, height: originalSize.height)
            }
            
        case .top, .bottom:
            // 세로만 조정
            if let resizableShape = shape as? ResizableShape {
                let heightDelta = (activeHandle == .bottom) ? delta.y : -delta.y
                let newHeight = max(50, originalSize.height + heightDelta)
                resizableShape.customSize = CGSize(width: originalSize.width, height: newHeight)
            }
            
        case .none:
            return
        }
        
        if let _ = shapeManager.shapes.popLast() {
            shapeManager.addShape(shape: shape)
        }
    }
    
    public func handleDragEnd(shapeManager: ShapeManager, point: CGPoint) {
        activeHandle = .none
        startPoint = nil
        originalTransform = nil
        originalSize = nil
    }
    
    public func handleDragCancel(shapeManager: ShapeManager, point: CGPoint) {
        if let shape = selectedShape, let originalTransform = originalTransform {
            shape.transform = originalTransform
        }
        activeHandle = .none
    }
    
    // MARK: - Helper Methods
    
    private func calculateCornerScale(handle: ResizeHandle, delta: CGPoint, originalSize: CGSize) -> CGFloat {
        let diagonal = sqrt(originalSize.width * originalSize.width + originalSize.height * originalSize.height)
        
        var effectiveDelta: CGFloat = 0
        switch handle {
        case .bottomRight:
            effectiveDelta = (delta.x + delta.y) / 2
        case .bottomLeft:
            effectiveDelta = (-delta.x + delta.y) / 2
        case .topRight:
            effectiveDelta = (delta.x - delta.y) / 2
        case .topLeft:
            effectiveDelta = (-delta.x - delta.y) / 2
        default:
            break
        }
        
        let scale = 1 + (effectiveDelta / diagonal) * 2
        return max(0.3, min(3.0, scale))
    }
    
    public func hitTestHandle(shape: TransformSelectable, point: CGPoint) -> ResizeHandle {
        let handleSize: CGFloat = 30
        let handles = getHandleRects(shape: shape, handleSize: handleSize)
        
        for (handle, rect) in handles {
            if rect.contains(point) {
                return handle
            }
        }
        return .none
    }
    
    public func getHandleRects(shape: TransformSelectable, handleSize: CGFloat = 20) -> [(ResizeHandle, CGRect)] {
        let bounds = shape.boundingRect
        let transform = shape.transform
        
        let scaledWidth = bounds.width * transform.scale
        let scaledHeight = bounds.height * transform.scale
        
        let origin = transform.translation
        let halfHandle = handleSize / 2
        
        return [
            // 꼭지점
            (.topLeft, CGRect(x: origin.x - halfHandle, y: origin.y - halfHandle, width: handleSize, height: handleSize)),
            (.topRight, CGRect(x: origin.x + scaledWidth - halfHandle, y: origin.y - halfHandle, width: handleSize, height: handleSize)),
            (.bottomLeft, CGRect(x: origin.x - halfHandle, y: origin.y + scaledHeight - halfHandle, width: handleSize, height: handleSize)),
            (.bottomRight, CGRect(x: origin.x + scaledWidth - halfHandle, y: origin.y + scaledHeight - halfHandle, width: handleSize, height: handleSize)),
            // 변 중앙
            (.top, CGRect(x: origin.x + scaledWidth/2 - halfHandle, y: origin.y - halfHandle, width: handleSize, height: handleSize)),
            (.bottom, CGRect(x: origin.x + scaledWidth/2 - halfHandle, y: origin.y + scaledHeight - halfHandle, width: handleSize, height: handleSize)),
            (.left, CGRect(x: origin.x - halfHandle, y: origin.y + scaledHeight/2 - halfHandle, width: handleSize, height: handleSize)),
            (.right, CGRect(x: origin.x + scaledWidth - halfHandle, y: origin.y + scaledHeight/2 - halfHandle, width: handleSize, height: handleSize)),
        ]
    }
}

// 크기 조절 가능한 Shape 프로토콜
public protocol ResizableShape: TransformSelectable {
    var customSize: CGSize? { get set }
}

//
//  DrawingShape.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 12/21/25.
//
import Foundation

public struct PenData: Codable {
    var id: String
    var isFinished: Bool
    var start: CGPoint
    var strokeColor: String
    var strokeWidth: CGFloat
    var segments: [PenLineSegment]
    var isEraser: Bool
    var transform: ShapeTransform
    
}

public struct RectData: Codable {
    var id: String
    var a: CGPoint
    var b: CGPoint
    var fillColor: String
    var dashPhase: CGFloat?
    var dashLengths: [CGFloat]?
    var transform: ShapeTransform
}

public struct TextData: Codable {
    var id: String
    var transform: ShapeTransform
    var text: String
    var fontName: String
    var textColor: String
    var explicitWidth: CGFloat
    var boundingRect: CGRect
}

public enum DrawingShape: Codable {
    case pen(PenData)
    case rect(RectData)
    case text(TextData)
}

extension DrawingShape {
    func toData() -> Data? {
        do {
            let data = try JSONEncoder().encode(self)
            return data
        } catch {
            print("디코딩 실패: \(error)")
            return nil
        }
    }
}

extension Data {
    func toDrawingShape() -> DrawingShape? {
        do {
            return try JSONDecoder().decode(DrawingShape.self, from: self)
        } catch {
            print("디코딩 실패: \(error)")
            return nil
        }
    }
}


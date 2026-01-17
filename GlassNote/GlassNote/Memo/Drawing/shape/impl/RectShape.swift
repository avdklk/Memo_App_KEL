//
//  RectShape.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 11/28/25.
//
import UIKit

public class RectShape: ShapeWithTwoPoints,
                        ShapeWithStandardState,
                        ShapeSelectable {
    
    private enum CodingKeys: String, CodingKey {
      case id, a, b, fillColor,
      dashPhase, dashLengths, transform, type
    }
    
    public let type: String = "Rectangle"

    public var id: String = UUID().uuidString
    public var a: CGPoint = .zero
    public var b: CGPoint = .zero
    public var strokeColor: UIColor? = nil
    public var fillColor: UIColor? = .clear
    public var strokeWidth: CGFloat = 10
    public var capStyle: CGLineCap = .round
    public var joinStyle: CGLineJoin = .round
    public var dashPhase: CGFloat?
    public var dashLengths: [CGFloat]?
    public var transform: ShapeTransform = .identity
    public var createdAt: Date?
    
    public var boundingRect: CGRect {
        let maxX = max(a.x, b.x)
        let minX = min(a.x, b.x)
        let maxY = max(a.y, b.y)
        let minY = min(a.y, b.y)
        
        let minimalRect = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
        return minimalRect.insetBy(dx: -strokeWidth/2, dy: -strokeWidth/2)
    }
    
    public init() {

    }
    
    public init(rectData: RectData) {
        self.id = rectData.id
        self.a = rectData.a
        self.b = rectData.b
        self.fillColor = UIColor.init(hexString: rectData.fillColor)
        self.dashPhase = rectData.dashPhase
        self.dashLengths = rectData.dashLengths
        self.transform = rectData.transform
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        let type = try values.decode(String.self, forKey: .type)
        if type != type {
            throw DrawsanaDecodingError.wrongShapeTypeError
        }
        
        id = try values.decode(String.self, forKey: .id)
        a = try values.decode(CGPoint.self, forKey: .a)
        b = try values.decode(CGPoint.self, forKey: .b)
        fillColor = try values.decodeColorIfPresent(forKey: .fillColor)
        transform = try values.decodeIfPresent(ShapeTransform.self, forKey: .transform) ?? .identity
        
        dashPhase = try values.decodeIfPresent(CGFloat.self, forKey: .dashPhase)
        dashLengths = try values.decodeIfPresent([CGFloat].self, forKey: .dashLengths)
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(type, forKey: .type)
      try container.encode(id, forKey: .id)
      try container.encode(a, forKey: .a)
      try container.encode(b, forKey: .b)
      try container.encode(fillColor?.hexString, forKey: .fillColor)

      if !transform.isIdentity {
        try container.encode(transform, forKey: .transform)
      }

      try container.encodeIfPresent(dashPhase, forKey: .dashPhase)
      try container.encodeIfPresent(dashLengths, forKey: .dashLengths)
    }

    public func render(in context: CGContext) {
      transform.begin(context: context)

      if let fillColor = fillColor {
        context.setFillColor(fillColor.cgColor)
        context.addRect(rect)
        context.fillPath()
      }
      
      transform.end(context: context)
    }
    
    public func getData() -> DrawingShape {
        let rectData = RectData(id: id, a: a, b: b, fillColor: fillColor?.hexString ?? "#000000", transform: transform)
        return DrawingShape.rect(rectData)
    }
  }

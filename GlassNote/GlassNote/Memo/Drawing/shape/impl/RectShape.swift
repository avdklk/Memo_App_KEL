//
//  RectShape.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 11/28/25.
//
import UIKit

public class RectShape: TwoPointsShape {
    private enum CodingKeys: String, CodingKey {
        case id, point, strokeColor, fillColor, strokeWidth, capStyle, joinStyle,
      dashPhase, dashLengths, transform, type
    }
    
    public var strokeColor: String = "#000000"
    public var fillColor: String = "#000000"
    public var strokeWidth: CGFloat = 10
    public var capStyle: CGLineCap = .round
    public var joinStyle: CGLineJoin = .round
    public var dashPhase: CGFloat?
    public var dashLengths: [CGFloat]?
    public var transform: ShapeTransform = .identity

    public override init() {
        super.init()
        type = "Rectangle"
        dashPhase = 0.5
        dashLengths = [1, 1]
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
      let values = try decoder.container(keyedBy: CodingKeys.self)

      let type = try values.decode(String.self, forKey: .type)
      if type != type {
        throw DrawsanaDecodingError.wrongShapeTypeError
      }

      id = try values.decode(String.self, forKey: .id)
      point = try values.decode(ShapeWithTwoPoints.self, forKey: .point)
        strokeColor = try values.decode(String.self, forKey: .strokeColor)
      fillColor = try values.decode(String.self, forKey: .fillColor)
      strokeWidth = try values.decode(CGFloat.self, forKey: .strokeWidth)
      transform = try values.decodeIfPresent(ShapeTransform.self, forKey: .transform) ?? .identity

      capStyle = CGLineCap(rawValue: try values.decodeIfPresent(Int32.self, forKey: .capStyle) ?? CGLineCap.round.rawValue)!
      joinStyle = CGLineJoin(rawValue: try values.decodeIfPresent(Int32.self, forKey: .joinStyle) ?? CGLineJoin.round.rawValue)!
      dashPhase = try values.decodeIfPresent(CGFloat.self, forKey: .dashPhase)
      dashLengths = try values.decodeIfPresent([CGFloat].self, forKey: .dashLengths)
    }

    public override func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(type, forKey: .type)
      try container.encode(id, forKey: .id)
      try container.encode(point, forKey: .point)
      try container.encode(strokeColor, forKey: .strokeColor)
      try container.encode(fillColor, forKey: .fillColor)
      try container.encode(strokeWidth, forKey: .strokeWidth)

      if !transform.isIdentity {
        try container.encode(transform, forKey: .transform)
      }

      if capStyle != .round {
        try container.encode(capStyle.rawValue, forKey: .capStyle)
      }
      if joinStyle != .round {
        try container.encode(joinStyle.rawValue, forKey: .joinStyle)
      }
      try container.encodeIfPresent(dashPhase, forKey: .dashPhase)
      try container.encodeIfPresent(dashLengths, forKey: .dashLengths)
    }

    public override func render(in context: CGContext) {
      transform.begin(context: context)

      if let fillColor = UIColor.init(hex: fillColor) {
          context.setFillColor(UIColor.clear.cgColor) //Q
          context.addRect(point.rect) //Q
        context.fillPath()
      }
      
      context.setLineCap(capStyle)
      context.setLineJoin(joinStyle)
      context.setLineWidth(strokeWidth)

      if let strokeColor = UIColor.init(hex: strokeColor) {
        context.setStrokeColor(strokeColor.cgColor)
        if let dashPhase = dashPhase, let dashLengths = dashLengths {
          context.setLineDash(phase: dashPhase, lengths: dashLengths)
        } else {
          context.setLineDash(phase: 0, lengths: [])
        }
        context.addRect(point.rect)
        context.strokePath()
      }

      transform.end(context: context)
    }
}

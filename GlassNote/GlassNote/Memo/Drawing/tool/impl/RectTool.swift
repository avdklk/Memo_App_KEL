//
//  RectToll.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 11/28/25.
//
public class RectTool: DrawingToolForShapeWithTwoPoints {
  public override var name: String { return "Rectangle" }
  public override func makeShape() -> Shape { return RectShape() }
}


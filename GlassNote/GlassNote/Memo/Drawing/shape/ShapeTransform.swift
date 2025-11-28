//
//  ShapeTransform.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 11/27/25.
//
import CoreGraphics

/**
 Simplified representation of three ordered affine transforms (translate,
 rotate, scale) that can be applied to `ShapeWithTransform`.
 */

/**
 평행 이동, 회전, 스케일
 
 `ShapeWithTransform`에 적용할 수 있는,
 평행이동(translate)–회전(rotate)–스케일(scale)의
 세 가지 정렬된(ordered) 아핀 변환을 단순화한 표현.
 */
public struct ShapeTransform: Codable, Equatable {
  public var translation: CGPoint
  public var rotation: CGFloat
  public var scale: CGFloat

  public static let identity = ShapeTransform(translation: .zero, rotation: 0, scale: 1)
}

extension ShapeTransform {
  /// Returns `true` iff this shape has zero translation, zero rotation, and 1 scale
    
    ////// 이 변환이 translation=0, rotation=0, scale=1 인 경우에만 true를 반환한다.
  public var isIdentity: Bool {
    return translation.x == 0 && translation.y == 0 && rotation == 0 && scale == 1
  }

  /// Representation of this transform as a `CGAffineTransform`
    
    ///  /// 이 변환을 `CGAffineTransform` 형태로 반환한다.
  public var affineTransform: CGAffineTransform {
    return CGAffineTransform(translationX: translation.x, y: translation.y)
      .rotated(by: rotation)
      .scaledBy(x: scale, y: scale)
  }

  /// Apply this transform in Core Graphics
    
    /// /// Core Graphics 컨텍스트에 이 변환을 적용한다.
  public func begin(context: CGContext) {
    context.saveGState()
    context.concatenate(affineTransform)
  }

  /// Unapply this transform in Core Graphics (must be paired with exactly one
  /// `begin(context:)` at the same GState nesting level!)
    
    /// /// Core Graphics 컨텍스트에서 이 변환을 해제한다.
    /// 반드시 동일한 GState 깊이에서 단 하나의 `begin(context:)`와 쌍을 이뤄야 한다!
  public func end(context: CGContext) {
    context.restoreGState()
  }

  /// Return a copy of this transform with its translation moved by the given
  /// amount
    
    ///  /// translation 값을 지정된 delta만큼 이동한 변환 사본을 반환한다.
  public func translated(by delta: CGPoint) -> ShapeTransform {
    return ShapeTransform(
      translation: CGPoint(x: translation.x + delta.x, y: translation.y + delta.y),
      rotation: rotation,
      scale: scale)
  }

  /// Return a copy of this transform with its scale multiplied by the given
  /// amount
    
    ///  /// scale 값을 지정된 amount만큼 곱한 변환 사본을 반환한다.
  public func scaled(by amount: CGFloat) -> ShapeTransform {
    return ShapeTransform(
      translation: translation,
      rotation: rotation,
      scale: scale * amount)
  }

  /// Return a copy of this transform with its rotation changed by the given
  /// amount
    
    /// /// rotation 값을 지정된 라디안 만큼 변경한 변환 사본을 반환한다.
  public func rotated(by radians: CGFloat) -> ShapeTransform {
    return ShapeTransform(
      translation: translation,
      rotation: rotation + radians,
      scale: scale)
  }
}


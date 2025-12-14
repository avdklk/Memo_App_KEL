//
//  Shape.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 11/24/25.
//
import SwiftUI

public protocol Shape: AnyObject, Codable {
    /// 이 도형을 전역적으로 구분하기 위한 고유 식별자.
      /// 특히 네트워크 기반 업데이트에서 동일성(equality) 비교를 위해 사용된다.
    var id: String { get set }
    
    /// 이 도형의 문자열 타입. 직렬화(serialization) 및 디버깅 용도로 사용된다.
    static var type: String { get }
    
    /// 주어진 Core Graphics 컨텍스트에 이 도형을 그린다.
    /// 위치 및 스케일에 대한 변환(transform)은 이미 적용된 상태다.
    func render(in context: CGContext)
    
    /// 주어진 포인트가 이 도형이 그린 픽셀들과 실질적으로 교차하는 경우 true를 반환한다.
    /// 간단한 구현 방법은 `ShapeWithBoundingRect`를 참고하라.
    func hitTest(point: CGPoint) -> Bool
    
    /// `userSettings`에 포함된 색상, 크기, 폰트 등의 설정을
    /// 이 도형에 적용한다.
    func apply(userSettings: UserSettings)
}

/**
 `Shape` 프로토콜의 확장 버전으로,
 `boundingRect` 프로퍼티만 제공하면 `hitTest`를 자동으로 구현해주는 프로토콜.
 */
public protocol ShapeWithBoundingRect: Shape {
  var boundingRect: CGRect { get }
}

extension ShapeWithBoundingRect {
  public func hitTest(point: CGPoint) -> Bool {
    return boundingRect.contains(point)
  }
}


/**
 Enhancement to `Shape` protocol that has a `transform` property, meaning it can
 be translated, rotated, and scaled relative to its original characteristics.
 */

/**
 `Shape` 프로토콜의 확장 버전으로,
 `transform` 프로퍼티를 사용해 도형을 원래 특성 기준에서
 평행이동, 회전, 스케일 조정할 수 있도록 한다.
 */
public protocol ShapeWithTransform: Shape {
  var transform: ShapeTransform { get set }
}

/**
 Enhancement to `Shape` protocol that enforces requirements necessary for a
 shape to be used with the selection tool. This includes
 `ShapeWithBoundingRect` to render the selection rect around the shape, and
 `ShapeWithTransform` to allow the shape to be moved from its original
 position
 */

/**
 선택 도구(selection tool)와 함께 사용하기 위해 필요한 요구사항을 강제하는
 `Shape` 프로토콜의 확장 버전.
 여기에는 도형 주변에 선택 영역을 그리기 위한 `ShapeWithBoundingRect`,
 그리고 도형을 원래 위치에서 이동할 수 있도록 하는 `ShapeWithTransform`이 포함된다.
 */
public protocol ShapeSelectable: ShapeWithBoundingRect, ShapeWithTransform {
}

extension ShapeSelectable {
  public func hitTest(point: CGPoint) -> Bool {
    return boundingRect.applying(transform.affineTransform).contains(point)
  }
}

/**
 Enhancement to `Shape` adding properties to match all `UserSettings`
 properties. There is a convenience method `apply(userSettings:)` which updates
 the shape to match the given values.
 */

/**
 `Shape`에 `UserSettings`의 모든 속성과 대응되는 프로퍼티들을 추가하는 확장이다.
 `apply(userSettings:)` 메서드를 사용하면 지정된 설정 값들을 손쉽게 도형에 적용할 수 있다.
 */
public protocol ShapeWithStandardState: AnyObject {
  var strokeColor: UIColor? { get set }
  var fillColor: UIColor? { get set }
  var strokeWidth: CGFloat { get set }
}

extension ShapeWithStandardState {
  public func apply(userSettings: UserSettings) {
    strokeColor = userSettings.strokeColor
    fillColor = userSettings.fillColor
    strokeWidth = userSettings.strokeWidth
  }
}

/**
 Like `ShapeWithStandardState`, but ignores `UserSettings.fillColor`.
 */

/**
 `ShapeWithStandardState`와 비슷하지만, `UserSettings.fillColor`는 무시한다.
 */
public protocol ShapeWithStrokeState: AnyObject {
  var strokeColor: UIColor { get set }
  var strokeWidth: CGFloat { get set }
}

extension ShapeWithStrokeState {
  public func apply(userSettings: UserSettings) {
    strokeColor = userSettings.strokeColor ?? .black
    strokeWidth = userSettings.strokeWidth
  }
}


public protocol ShapeWithTwoPoints {
  var a: CGPoint { get set }
  var b: CGPoint { get set }

  var strokeWidth: CGFloat { get set }
}

extension ShapeWithTwoPoints {
  public var rect: CGRect {
    let x1 = min(a.x, b.x)
    let y1 = min(a.y, b.y)
    let x2 = max(a.x, b.x)
    let y2 = max(a.y, b.y)
    return CGRect(x: x1, y: y1, width: x2 - x1, height: y2 - y1)
  }
    
    public var squareRect: CGRect {
        let width = min(abs(b.x - a.x), abs(b.y - a.y))
        let x = b.x < a.x ? a.x - width : a.x
        let y = b.y < a.y ? a.y - width : a.y
        return CGRect(x: x, y: y, width: width, height: width)
    }
    

  public var boundingRect: CGRect {
    return rect.insetBy(dx: -strokeWidth/2, dy: -strokeWidth/2)
  }
}

/**
 Special case of `Shape` where the shape is defined by exactly three points.
 */
public protocol ShapeWithThreePoints {
  var a: CGPoint { get set }
  var b: CGPoint { get set }
  var c: CGPoint { get set }
  
  var strokeWidth: CGFloat { get set }
}

extension ShapeWithThreePoints {
  public var rect: CGRect {
    let x1 = min(a.x, b.x, c.x)
    let y1 = min(a.y, b.y, c.y)
    let x2 = max(a.x, b.x, c.x)
    let y2 = max(a.y, b.y, c.y)
    return CGRect(x: x1, y: y1, width: x2 - x1, height: y2 - y1)
  }
  
  public var boundingRect: CGRect {
    return rect.insetBy(dx: -strokeWidth/2, dy: -strokeWidth/2)
  }
}

//
//  Drawing.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 11/24/25.
//
import Foundation

public final class Drawing: Codable {
    private enum CodingKeys: String, CodingKey {
      case size
      case shapes
    }

    private enum ShapeTypeCodingKey: String, CodingKey {
      case type
    }
    
    var shapes: [Shape]
    var size: CGSize
    public static var debugSerialization = false
    public var shapeDecoder: ((MultiDecoder<Shape>) -> Void)?

    init(size: CGSize) {
        self.shapes = []
        self.size = size
    }
    
    init(shapes: [Shape], size: CGSize) {
        self.shapes = shapes
        self.size = size
    }
    
    public required init(from decoder: Decoder) throws {
        // 이 이니셜라이저는 다양한 타입의 도형 배열을 디코딩해야 하기 때문에
        // 꽤 복잡한 편이다.
      let container = try decoder.container(keyedBy: CodingKeys.self)

        // size는 단순하다:
      size = try container.decode(CGSize.self, forKey: .size)

        // shapes 배열을 디코딩하기 위해, 먼저 컨테이너의 iterator를 만들고
        // 대상 배열(self.shapes)은 비어 있는 상태로 초기화한다.
      shapes = []
      var shapeIter = try container.nestedUnkeyedContainer(forKey: .shapes)

      while !shapeIter.isAtEnd {
          // 디코딩 실패 여부를 파악하기 위해 기존 count를 저장해둔다.
        let countBefore = shapes.count

          // 가능한 모든 도형 타입을 이 iterator로 디코딩 시도한다.
          // 참고: `tryDecodingAllShapes(_:)`에서 사용하는 순서대로 도형이 나열되어 있다면
          // 이 과정에서 여러 개의 도형이 한 번에 디코딩될 수도 있다.
          do {
          try shapes.append(contentsOf: decodeAllShapes(&shapeIter))
              for shape in shapes {
                  print(shape)
              }
        } catch {
//          if Drawing.debugSerialization {
            throw error
//          }
        }


        // 디코딩에 실패한 경우, 도움 되는 에러 메시지를 남기며 중단한다.
          // (현재는 crash를 선택했지만, 나중에는 커스텀 에러 enum을 사용하는 것도 고려 가능)
        if shapes.count == countBefore {
            // 어떤 타입이 파싱 실패했는지 정확히 보고하기 위해
                // `type`만 관심 갖는 특별한 CodingKeys enum을 사용한다.
          let typeContainer = try shapeIter.nestedContainer(keyedBy: ShapeTypeCodingKey.self)
          let type = try typeContainer.decode(String.self, forKey: .type)

            // debug 모드에서는 에러를 던지고, 아닌 경우는 그냥 무시하고 넘어간다.
          if Drawing.debugSerialization {
            throw DrawsanaDecodingError.unknownShapeTypeError(type)
          }
        }
      }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(size, forKey: .size)
        // The Swift compiler can't figure out how to encode a heterogeneous array
        // of shapes, so we use this type system trick to turn a confusing "Shape"
        // into a non-confusing "Encodable", and for some reason the Swift compiler
        // accepts this and behaves correctly.
        try? container.encode(shapes.map({ AnyEncodable(base: $0) }), forKey: .shapes)
    }
    
    private func decodeAllShapes(_ container: inout UnkeyedDecodingContainer) throws -> [Shape] {
      let multiDecoder = MultiDecoder<Shape>(container: &container)
//      try multiDecoder.decode(EllipseShape.self)
//      try multiDecoder.decode(LineShape.self)
      try? multiDecoder.decode(PenShape.self)
      try? multiDecoder.decode(RectShape.self)
      try? multiDecoder.decode(TextShape.self)
//      try multiDecoder.decode(StarShape.self)
//      try multiDecoder.decode(NgonShape.self)
      shapeDecoder?(multiDecoder)
      container = multiDecoder.container
      return multiDecoder.results
    }
    
    
}

public enum DrawsanaDecodingError: Error {
  case wrongShapeTypeError
  case unknownShapeTypeError(String)
}

// MARK: Codable helpers

/// Wrap any non-concrete `Encodable` type (like a `Shape`) in this class to
/// magically make it work with `container.encode(foo, forKey: .foo)`.
private struct AnyEncodable: Encodable {
  let base: Encodable

  func encode(to encoder: Encoder) throws {
    try base.encode(to: encoder)
  }
}

/// Simple pattern for trying to decode array elements as multiple types.
public class MultiDecoder<ResultType> {
  var container: UnkeyedDecodingContainer
  var results = [ResultType]()

  init(container: inout UnkeyedDecodingContainer) {
    self.container = container
  }

  /// Adds the decoded result to `results` if decoding succeeds. If decoding
  /// fails because the shape type doesn't match, do nothing. Throws all other
  /// errors.
  ///
  /// Another way to put it is that this method catches
  /// `DrawsanaDecodingError.wrongShapeTypeError` and
  /// `Swift.DecodingError.valueNotFound`.
  public func decode<T: Shape>(_ type: T.Type) throws {
    do {
      results.append(try container.decode(T.self) as! ResultType)
    } catch Swift.DecodingError.valueNotFound {
      return
    } catch DrawsanaDecodingError.wrongShapeTypeError {
      return
    }
  }
}

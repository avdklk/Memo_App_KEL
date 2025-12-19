//
//  ToolSettings.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 12/3/25.
//

import UIKit

/**
 Collection of properties for use by tools. Unlike `UserSettings`, these
 properties are meant to be set by the tools themselves.
 */

/**
 도구(tool)에서 사용하기 위한 프로퍼티 모음.
 `UserSettings`와 달리, 이 프로퍼티들은 도구 자체가 직접 설정하도록 만들어졌다.
 */
public class ToolSettings {
  weak var delegate: ToolSettingsDelegate?

  /// Shape which should have the selection rect drawn around it. May also be
  /// used by tools to keep track of some "active" shape. (The text tool does
  /// this.)
    ///
    
    /// 선택 영역(selection rect)이 그려져야 하는 도형.
     /// 또는 도구가 “활성(active)” 상태의 도형을 추적하는 용도로도 사용될 수 있다.
     /// (텍스트 도구가 이 방식을 사용한다.)
  public var selectedShape: ShapeSelectable? {
    didSet {
      delegate?.toolSettings(self, didSetSelectedShape: selectedShape)
    }
  }

  /// This view, if non-nil, is added to the view hierarchy above the drawing
  /// so that the user may interact with it. The tool is responsible for
  /// setting its frame.
    
    /// 이 뷰가 nil이 아니면, 드로잉 뷰 위에 view hierarchy에 추가되어
     /// 사용자가 직접 상호작용할 수 있게 된다.
     /// 해당 뷰의 frame을 설정하는 책임은 도구(tool)에 있다.
  public var interactiveView: UIView? {
    didSet {
      delegate?.toolSettings(self, didSetInteractiveView: interactiveView, oldValue: oldValue)
    }
  }

  /// Set this to `true` if you have modified a shape that is already added
  /// to the drawing. `DrawingView` checks it each frame during tool operations
  /// and regenerates its buffer accordingly.
  ///
  /// WARNING: Redrawing the buffer is slow!
    ///
    
    /// 이미 드로잉에 추가된 도형을 수정했다면 이 값을 `true`로 설정한다.
     /// `DrawingView`는 도구 작업 중 매 프레임마다 이 값을 검사해서
     /// 필요하면 버퍼를 다시 생성한다.
     ///
     /// ⚠️ 경고: 버퍼를 다시 그리는 작업은 느리다!
  public var isPersistentBufferDirty: Bool {
    didSet {
      delegate?.toolSettings(self, didSetIsPersistentBufferDirty: isPersistentBufferDirty)
    }
  }

  init(selectedShape: ShapeSelectable?, interactiveView: UIView?, isPersistentBufferDirty: Bool) {
    self.selectedShape = selectedShape
    self.interactiveView = interactiveView
    self.isPersistentBufferDirty = isPersistentBufferDirty
  }
}

protocol ToolSettingsDelegate: AnyObject {
  func toolSettings(
    _ toolSettings: ToolSettings,
    didSetSelectedShape selectedShape: ShapeSelectable?)

  func toolSettings(
    _ toolSettings: ToolSettings,
    didSetInteractiveView interactiveView: UIView?,
    oldValue: UIView?)

  func toolSettings(
    _ toolSettings: ToolSettings,
    didSetIsPersistentBufferDirty isPersistentBufferDirty: Bool)
}


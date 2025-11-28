//
//  DrawingTool.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 11/24/25.
//
import Foundation
import CoreGraphics

public protocol DrawingTool: AnyObject {
    /// If `true`, the shape-in-progress buffer is not cleared at all during
    /// drawing operations. So if you're implementing something like a pen tool,
    /// you only need to draw the tail of the line that hasn't yet been drawn,
    /// and avoid the cost of re-rendering the whole shape as it gets longer.
      /// /// 만약 `true`라면, 도형이 그려지는 동안(`shape-in-progress buffer`)
      /// 버퍼가 전혀 지워지지 않습니다.
      ///
      /// 예를 들어, 펜 도구(pen tool)처럼 선을 점진적으로 그리는 툴이라면
      /// 이미 그려진 선 전체를 다시 렌더링할 필요 없이,
      /// “아직 그려지지 않은 부분의 꼬리 부분”만 새로 그리면 됩니다.
      /// 이렇게 하면 전체 도형을 반복적으로 다시 그리는 비용을 줄일 수 있습니다.
//    var isProgressive: Bool { get }

    /// Arbitrary string identifier. Useful for the demo UI, and potentially
    /// associating icons with each tool.
      /// 임의의 문자열 식별자입니다.
        /// 데모 UI나 각 툴에 아이콘을 연결할 때 유용하게 사용됩니다.
    var name: String { get }

    /**
     The user has picked this tool in the UI. The default implementation does
     nothing.

     - Parameters:
       - shapeUpdater: An object which you may inform of out-of-band shape updates.
         Normally, `DrawsanaView` only checks for changes during tool operations,
         but some tools (e.g. `TextTool`) make changes based on arbitrary user
         input and need a way to update the selection rect and such.
       - context:
       - shape: Tools may be activate with "initial shapes." One use case for this
         is the selection tool handling a double-tap on a text shape. The UI can
         choose to activate the text tool and immediately enter the edit state.
     
       사용자가 UI에서 이 툴을 선택했을 때 호출됩니다.
       기본 구현은 아무 동작도 하지 않습니다.

       - Parameters:
         - shapeUpdater:
           도형 업데이트를 외부에 알릴 때 사용하는 객체입니다.
           일반적으로 `DrawsanaView`는 툴이 동작 중일 때만 변화를 감지하지만,
           일부 툴(예: `TextTool`)은 사용자의 입력에 따라 별도로 도형을 업데이트할 필요가 있습니다.
           이 경우 selection rect(선택 영역) 등의 UI를 갱신하기 위해 `shapeUpdater`를 사용합니다.

         - context:
           현재 드로잉 작업에 대한 컨텍스트 (뷰, 레이어, 제스처 상태 등)

         - shape:
           툴이 “초기 도형(initial shape)”과 함께 활성화될 수도 있습니다.
           예를 들어, 텍스트 도형을 더블탭했을 때 선택 도구가
           자동으로 텍스트 툴을 활성화하고 즉시 편집 모드로 진입하는 경우가 있습니다.
     */
//    func activate(shapeUpdater: DrawsanaViewShapeUpdating, context: ToolOperationContext, shape: Shape?)
//
//    /// This tool has become deselected. The default implementation does nothing.
//    func deactivate(context: ToolOperationContext)

    func setSize(size: CGSize)
    /// User tapped on the drawing
    func handleTap(point: CGPoint)

    /// User has started to drag on the drawing
    func handleDragStart(point: CGPoint, colorHex: String) -> Shape

    /// User has continued to drag on the drawing
    func handleDragContinue(point: CGPoint, velocity: CGPoint) -> Shape?

    /// User has stopped to drag on the drawing
    func handleDragEnd(point: CGPoint)

    /// The drag gesture has canceled for some reason. The intended use case is
    /// for when the user places a second finger down, and this becomes a pinch
    /// instead of a drag.
    ///
    /// You probably want to clean up all in-progress updates and reset to a state
    /// as if the drag had never begun.
    func handleDragCancel(point: CGPoint)

    ///사용자 설정(UserSettings)이 변경
      ///
      /// User settings have changed. Update any local state or the shape, if
    /// relevant. The default implementation does nothing.
      /// 사용자 설정(UserSettings)이 변경되었습니다.
      /// 관련이 있다면, 로컬 상태나 도형을 업데이트하세요.
      /// 기본 구현은 아무 동작도 하지 않습니다.
//    func apply(context: CGContext, userSettings: UserSettings)

    /// After each invocation of `handleDragStart(context:point:)`,
    /// `handleDragContinue(context:point:velocity:)`, and
    /// `handleDragEnd(context:point:)`, this method is called. If your tool is
    /// in the process of creating a shape but it isn't yet committed to the
    /// drawing, render it to this `CGContext`.
    ///
    /// If `isProgressive` is `true`, you only need to render changes since the
    /// last call. Otherwise, you need to render the whole shape.
    ///
    /// The default implementation does nothing.
      ///  `handleDragStart(context:point:)`,
      /// `handleDragContinue(context:point:velocity:)`,
      /// `handleDragEnd(context:point:)` 가 호출된 이후마다 이 메서드가 실행됩니다.
      
      /// 그리는 중
      ///
      /// 만약 현재 툴이 “새로운 도형을 그리고 있지만 아직 완성되지 않은 상태”라면,
      /// 이 도형을 이 `CGContext` 위에 렌더링하세요.
      ///
      /// `isProgressive`가 `true`인 경우에는,
      /// 이전 호출 이후의 **변화된 부분만** 렌더링하면 됩니다.
      ///
      /// 반대로 `isProgressive`가 `false`인 경우에는
      /// **전체 도형을 다시 렌더링해야 합니다.**
      ///
      /// 기본 구현은 아무 동작도 하지 않습니다.
    func renderShapeInProgress(transientContext: CGContext)
  }
  // TODO: Should we put these in a base class instead? Do they prevent subclass
  // method overrides from being used in practice?
  public extension DrawingTool {
//    func activate(shapeUpdater: DrawsanaViewShapeUpdating, context: CGContext, shape: Shape?) { }
//    func deactivate(context: CGContext) { }
//    func apply(context: CGContext, userSettings: UserSettings) { }
    func renderShapeInProgress(transientContext: CGContext) { }
    func setSize(size: CGSize) {}
  }

public protocol DrawsanaViewShapeUpdating: AnyObject {
  func rerenderAllShapesInefficiently()
}


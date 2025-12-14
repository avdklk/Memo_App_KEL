//
//  ToolOperationContext.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 12/3/25.
//
import Foundation

/**
 Aggregate of objects that may be used by tools during operations
 */
public struct ToolOperationContext {
  public let drawing: Drawing
  public let operationStack: DrawingOperationStack
  public let userSettings: UserSettings
  public let toolSettings: ToolSettings
}


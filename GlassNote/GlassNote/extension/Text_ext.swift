//
//  Label_ext.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 1/31/26.
//
import SwiftUI

extension Text {
    func setDefualtGradient() -> Text{
        self.foregroundStyle(
        LinearGradient(
            colors: [
                Color.black.opacity(1.0),
                Color.blue.opacity(0.7),
                Color.purple.opacity(0.8)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        )
    }
}

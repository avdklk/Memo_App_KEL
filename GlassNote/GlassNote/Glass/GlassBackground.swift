//
//  GlassBackground.swift
//  GlassNote
//
//  Created by 전영현 on 11/18/25.
//

import SwiftUI

struct GlassBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color.black.opacity(1.0),
                Color.blue.opacity(0.7),
                Color.purple.opacity(0.8)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

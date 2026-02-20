//
//  GlassContainer.swift
//  GlassNote
//
//  Created by 전영현 on 11/18/25.
//

import SwiftUI
struct ClearContainer<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    .clear
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(
                            Color.white,
                            lineWidth: 1
                        )
                )
                .shadow(radius: 20)
            
            content
                .padding(18)
        }
    }
}

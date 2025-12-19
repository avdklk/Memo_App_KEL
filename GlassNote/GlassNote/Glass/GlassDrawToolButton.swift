//
//  GlassDrawToolButton.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 12/9/25.
//

import SwiftUI


struct GlassDrawToolButton: View {
    let systemName: String
    @State var isSelected: Bool = false
    var action: () -> Void
    
    var body: some View {
        Button (action: {
            action()
            isSelected.toggle()
        }){
            Image(systemName: systemName)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(
                    isSelected
                    ? Color.white.opacity(0.22)
                    : Color.white.opacity(0.08)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .strokeBorder(
                            Color.white.opacity(isSelected ? 0.6 : 0.2),
                            lineWidth: 1
                        )
                )
        )
        .buttonStyle(.plain)
        .foregroundColor(.white)
    }
}


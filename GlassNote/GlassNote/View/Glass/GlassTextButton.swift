//
//  GlassTextButton.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 1/8/26.
//
import SwiftUI

struct GlassTextButton: View {
    let title: String
    var isSelected: Bool = false
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .padding([.top, .bottom], 10)
                .padding([.leading, .trailing], 5)
                .background(
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(
                            isSelected
                            ? Color.white.opacity(0.22)
                            : Color.white.opacity(0.08)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .strokeBorder(
                                    Color.white.opacity(isSelected ? 0.6 : 0.2),
                                    lineWidth: 1
                                )
                        )
                )
        }
        .buttonStyle(.plain)
        .foregroundColor(.white)
    }
}

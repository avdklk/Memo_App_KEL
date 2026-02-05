//
//  GlassDrawToolButton.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 12/9/25.
//

import SwiftUI


struct GlassDrawToolButton: View {
    let systemName: String
    let myToolType: ToolType?
    var nowToolType: ToolType?
    var isSelected: Bool = false
    var action: () -> Void
    
    private var backgroundColor: Color {
        if let myToolType = myToolType, let nowToolType = nowToolType, myToolType == nowToolType {
            return Color.white.opacity(0.22)
        }
        return isSelected ? Color.white.opacity(0.22) : Color.white.opacity(0.08)
    }
    
    private var borderColor: Color {
        if let myToolType = myToolType, let nowToolType = nowToolType, myToolType == nowToolType {
            return Color.white.opacity(0.6)
        }
        return isSelected ? Color.white.opacity(0.6) : Color.white.opacity(0.2)
    }
    
    var body: some View {
        Button (action: {
            action()
        }){
            Image(systemName: systemName)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .strokeBorder(borderColor,lineWidth: 1)
                )
        )
        .buttonStyle(.plain)
        .foregroundColor(.white)
    }
}


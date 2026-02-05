//
//  ResizeHandleOverlay.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 1/26/26.
//

import SwiftUI

struct ResizeHandleOverlay: View {
    let shape: TransformSelectable
    let activeHandle: ResizeHandle
    
    private let handleSize: CGFloat = 12
    private let borderColor = Color.blue
    private let handleColor = Color.white
    private let handleBorderColor = Color.blue
    
    var body: some View {
        let bounds = shape.boundingRect
        let transform = shape.transform
        
        let scaledWidth = bounds.width * transform.scale
        let scaledHeight = bounds.height * transform.scale
        let origin = transform.translation
        
        ZStack {
            // 테두리 선
            Rectangle()
                .stroke(borderColor, lineWidth: 2)
                .frame(width: scaledWidth, height: scaledHeight)
                .position(x: origin.x + scaledWidth / 2, y: origin.y + scaledHeight / 2)
            
            // 꼭지점 핸들
            handleView(for: .topLeft, x: origin.x, y: origin.y)
            handleView(for: .topRight, x: origin.x + scaledWidth, y: origin.y)
            handleView(for: .bottomLeft, x: origin.x, y: origin.y + scaledHeight)
            handleView(for: .bottomRight, x: origin.x + scaledWidth, y: origin.y + scaledHeight)
            
            // 변 중앙 핸들
            edgeHandleView(for: .top, x: origin.x + scaledWidth / 2, y: origin.y)
            edgeHandleView(for: .bottom, x: origin.x + scaledWidth / 2, y: origin.y + scaledHeight)
            edgeHandleView(for: .left, x: origin.x, y: origin.y + scaledHeight / 2)
            edgeHandleView(for: .right, x: origin.x + scaledWidth, y: origin.y + scaledHeight / 2)
        }
    }
    
    // 꼭지점 핸들 (정사각형)
    @ViewBuilder
    private func handleView(for handle: ResizeHandle, x: CGFloat, y: CGFloat) -> some View {
        let isActive = activeHandle == handle
        
        RoundedRectangle(cornerRadius: 2)
            .fill(isActive ? handleBorderColor : handleColor)
            .frame(width: handleSize, height: handleSize)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(handleBorderColor, lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
            .position(x: x, y: y)
    }
    
    // 변 핸들 (직사각형)
    @ViewBuilder
    private func edgeHandleView(for handle: ResizeHandle, x: CGFloat, y: CGFloat) -> some View {
        let isActive = activeHandle == handle
        let isHorizontal = (handle == .top || handle == .bottom)
        
        RoundedRectangle(cornerRadius: 2)
            .fill(isActive ? handleBorderColor : handleColor)
            .frame(width: isHorizontal ? handleSize * 1.5 : handleSize * 0.8,
                   height: isHorizontal ? handleSize * 0.8 : handleSize * 1.5)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(handleBorderColor, lineWidth: 1.5)
            )
            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
            .position(x: x, y: y)
    }
}

//
//  LiquidGlassNoteCard.swift
//  GlassNote
//
//  Created by jyh on 11/28/25.
//
import SwiftUI

struct LiquidGlassNoteCard: View {
    @ObservedObject var note: Note
    
    @State private var shineOffset: CGFloat = -180
    
    var body: some View {
        ZStack {
            //유리 배경
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color.white.opacity(0.10))
                )
                .overlay(glassOutline)
                .overlay(movingShineMask.mask(glassShape))
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .shadow(color: .black.opacity(0.35), radius: 14, x: 0, y: 6)
            
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(note.title ?? "Untitled")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(note.previewText ?? "")
                        .lineLimit(1)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text(note.updatedAt ?? Date(), style: .date)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.45))
                }
                
                Spacer()
                
                Image(systemName: "arrow.right.circle")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(20)
        }
        .frame(height: 90)
        .onAppear {
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                shineOffset = 200
            }
        }
    }
    
    private var glassShape: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
    }
    
    private var glassOutline: some View {
        RoundedRectangle(cornerRadius: 22)
            .stroke(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.55),
                        Color.white.opacity(0.15)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1.0
            )
    }
    
    private var movingShineMask: some View {
        LinearGradient(
            colors: [
                .clear,
                Color.white.opacity(0.4),
                .clear
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .rotationEffect(.degrees(35))
        .offset(x: shineOffset)
        .blur(radius: 18)
    }
}

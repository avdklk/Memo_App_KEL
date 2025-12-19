//
//  ContentView.swift
//  GlassNote
//
//  Created by jyh on 11/17/25.
//

import SwiftUI


struct ContentView: View {
    @State private var goToFiles = false
    @State private var isStartMemo = false
    
    var body: some View {
        ZStack {
            
            GlassBackground()
            
            VStack(spacing: 24) {
                GlassContainer {
                    VStack(spacing: 12) {
                        Image(systemName: "pencil.and.scribble")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text("Welcome to")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("GlassNote")
                            .font(.system(size: 34, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("A Liquid Glass note & sketch experience")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 28)
                }
                .padding(.horizontal, 32)
                
                // ★ 시작 버튼 (Glass 버튼 스타일)
                GlassToolButton(
                    systemName: "arrow.right.circle.fill",
                    title: "Start Note",
                    isSelected: true
                ) {
                    goToFiles = true
                }
                .fullScreenCover(isPresented: $goToFiles) {
                    FileSelete()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

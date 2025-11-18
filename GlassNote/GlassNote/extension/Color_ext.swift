//
//  Color_ext.swift
//  GlassNote
//
//  Created by 전영현 on 11/18/25.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hex)
        
        if hex.hasPrefix("#") { scanner.currentIndex = hex.index(after: hex.startIndex) }
        
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        self.init(
            .sRGB,
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255,
            opacity: 1
        )
    }
}

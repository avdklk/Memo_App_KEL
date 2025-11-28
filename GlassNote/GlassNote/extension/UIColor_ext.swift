//
//  UIColor_ext.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 11/25/25.
//
import UIKit

extension UIColor {
    convenience init?(hex: String, alpha: CGFloat = 1.0) {
        var sanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if sanitized.hasPrefix("#") {
            sanitized.remove(at: sanitized.startIndex)
        }

        // RGB 6자리(예: "FFAA00")만 처리
        guard sanitized.count == 6 else { return nil }

        var rgbValue: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&rgbValue)

        let r = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgbValue & 0x00FF00) >> 8)  / 255.0
        let b = CGFloat(rgbValue & 0x0000FF)         / 255.0

        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}


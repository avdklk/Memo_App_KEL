//
//  CGPoint_ext.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 12/6/25.
//
import CoreGraphics

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        let dx = point.x - self.x
        let dy = point.y - self.y
        return sqrt(dx*dx + dy*dy)
    }
}

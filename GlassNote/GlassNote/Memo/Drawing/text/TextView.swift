//
//  TextView.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 12/6/25.
//
import SwiftUI
import UIKit

struct TextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var rect: CGRect
    @Binding var isApplyText: Bool
    @Binding var isShowTextView: Bool
    @Binding var textWidth: CGFloat
    
    var userSettings: UserSettings
    
    func makeUIView(context: Context) -> TextMoveView {
        let view = TextMoveView(delegate: context.coordinator)
        return view
    }
    
    func updateUIView(_ uiView: TextMoveView, context: Context) {
        uiView.setFontSize(fontSize: textWidth)
        uiView.setText(text: text)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, TextMoveViewDelegate {
        var parent: TextView
        
        init(_ parent: TextView) {
            self.parent = parent
        }
        
        func editEnd(text: String, rect: CGRect) {
            parent.isApplyText = true
            parent.rect = rect
            parent.text = text
        }
        
        func editCancel() {
            parent.isShowTextView = false
        }
    }
}

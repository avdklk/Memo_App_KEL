//
//  View_ext.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 11/23/25.
//
import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func widthTooltip(isPresented: Binding<Bool>, title: String, toSize: CGFloat, value: Binding<CGFloat> ) -> some View {
        self.popover(isPresented: isPresented, arrowEdge: .top) {
            Text("\(title)\n\(Int(value.wrappedValue))")
                .multilineTextAlignment(.center)
                .frame(width: 180, alignment: .center)
                .padding([.top, .trailing, .leading], 15)
                .font(.system(size: 15))
                .presentationCompactAdaptation(.popover)
            
            Slider(value: value, in: 1...toSize)
                .padding([.trailing, .leading], 15)
            
            HStack {
                Text("1")
                    .font(.system(size: 15))
                Spacer()
                Text("\(Int(toSize / 2))")
                    .font(.system(size: 15))
                Spacer()
                Text("\(Int(toSize))")
                    .font(.system(size: 15))
            }
            .padding([.bottom, .trailing, .leading], 15)
        }
    }
}

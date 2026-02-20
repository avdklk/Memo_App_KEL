//
//  GlassOnOffButton.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 2/20/26.
//
import SwiftUI

struct GlassOnOffButton: View {
    let systemName: String
    let title: String
    var isSelected: Bool = false
    var isOn:Bool = false
    var action: () -> Void
    
    var body: some View {
        GeneralToolButton (action:{
            action()
        }, content: {
            HStack(spacing: 8) {
                Image(systemName: systemName)
                    .foregroundStyle(.white)
                    .font(.system(size: 14, weight: .semibold))
                Text(title)
                    .foregroundStyle(.white)
                    .font(.system(size: 13, weight: .medium))
                
                if isOn {
                    Text("ON")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.purple)
                        .cornerRadius(8)
                } else {
                    Text("OFF")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray)
                        .cornerRadius(8)
                }
            }
        })
    }
}

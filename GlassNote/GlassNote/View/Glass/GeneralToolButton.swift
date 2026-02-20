

import SwiftUI


struct GeneralToolButton<Contents: View>: View {
    var action: () -> Void
    var content: (() -> Contents)?
    var isSelected: Bool = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                content?()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        isSelected
                        ? Color.white.opacity(0.22)
                        : Color.white.opacity(0.08)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(
                                Color.white.opacity(isSelected ? 0.6 : 0.2),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
        .foregroundColor(.white)
    }
}

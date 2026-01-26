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
    
    func explainTooltip(isPresented: Binding<Bool>, title: String) -> some View {
        self.popover(isPresented: isPresented, arrowEdge: .top) {
            Text("\(title)")
                .multilineTextAlignment(.center)
                .frame(width: 180, alignment: .center)
                .padding([.top, .trailing, .leading], 15)
                .font(.system(size: 15))
                .presentationBackground(LinearGradient(
                    colors: [
                        Color.black.opacity(1.0),
                        Color.blue.opacity(0.7),
                        Color.purple.opacity(0.8)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .presentationCompactAdaptation(.popover)
        }
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
    
    func tooltip<Content: View>(isPresented: Binding<Bool>, title: String, toSize: CGFloat, value: Binding<CGFloat>, color: Binding<Color>? = nil, toolWidthArr: [CGFloat], contents: @escaping() -> Content) -> some View {
        self.popover(isPresented: isPresented, arrowEdge: .top) {
            VStack {
                Text("\(title)\n\(Int(value.wrappedValue))")
                    .multilineTextAlignment(.center)
                    .frame(width: 180, height: 40, alignment: .center)
                    .padding([.top], 10)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                
                Slider(value: value, in: 1...toSize)
                    .padding([.trailing, .leading], 15)
                
                HStack {
                    Text("1")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Text("\(Int(toSize / 2))")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Text("\(Int(toSize))")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                }
                .padding([.trailing, .leading], 15)
                
                Divider()
                    .frame(height: 1)
                    .background(Color.white)
                
                HStack(alignment: .center, spacing: 20) {
                    Button(action: {
                        value.wrappedValue = toolWidthArr[0]
                    }, label: { // label: 생략 가능
                        Circle()
                            .fill(color?.wrappedValue ?? .white)
                            .frame(width: 5, height: 5)
                    })
                    
                    Button(action: {
                        value.wrappedValue = toolWidthArr[1]
                    }, label: { // label: 생략 가능
                        Circle()
                            .fill(color?.wrappedValue ?? .white)
                            .frame(width: 10, height: 10)
                    })
                    
                    Button(action: {
                        value.wrappedValue = toolWidthArr[2]
                    }, label: { // label: 생략 가능
                        Circle()
                            .fill(color?.wrappedValue ?? .white)
                            .frame(width: 15, height: 15)
                    })
                    
                    Button(action: {
                        value.wrappedValue = toolWidthArr[3]
                    }, label: { // label: 생략 가능
                        Circle()
                            .fill(color?.wrappedValue ?? .white)
                            .frame(width: 20, height: 20)
                    })
                    
                    Button(action: {
                        value.wrappedValue = toolWidthArr[4]
                    }, label: { // label: 생략 가능
                        Circle()
                            .fill(color?.wrappedValue ?? .white)
                            .frame(width: 25, height: 25)
                    })
                }
                
                Divider()
                    .frame(height: 1)
                    .background(Color.white)
                
                contents()
                    .padding([.bottom], 10)
            }
            .presentationBackground(LinearGradient(
                colors: [
                    Color.black.opacity(1.0),
                    Color.blue.opacity(0.7),
                    Color.purple.opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
            .presentationCompactAdaptation(.popover)
        }
    }
    
    func tooltip(isPresented: Binding<Bool>, title: String, toSize: CGFloat, value: Binding<CGFloat>, color: Binding<Color>? = nil, toolWidthArr: [CGFloat]) -> some View {
        self.tooltip(isPresented: isPresented, title: title, toSize: toSize, value: value, color: color, toolWidthArr: toolWidthArr){
            EmptyView()
        }
    }
    
    func tooltip<Content: View>(isPresented: Binding<Bool>, edge: Edge, title: String, contents: @escaping() -> Content) -> some View {
        self.popover(isPresented: isPresented, arrowEdge: edge) {
            VStack {
                Text("\(title))")
                    .multilineTextAlignment(.center)
                    .frame(width: 180, height: 40, alignment: .center)
                    .padding([.top], 10)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                
                contents()
                    .padding([.bottom], 10)
            }
            .presentationBackground(LinearGradient(
                colors: [
                    Color.black.opacity(1.0),
                    Color.blue.opacity(0.7),
                    Color.purple.opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
            .presentationCompactAdaptation(.popover)
        }
    }
}

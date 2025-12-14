//
//  Untitled.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 11/23/25.
//
import SwiftUI

struct DrawView: View {
    @State private var didLoad = false
    @StateObject private var shapeManager = ShapeManager()
    @State var point: CGPoint = .zero
    @State var isShowTextView: Bool = false
    @State var text: String = ""
    @State var textRect: CGRect = .zero
    @State var changedColor: Color = .black
    @State var toolType: ToolType = .pen
    
    var body: some View {
        
        ZStack {
            GlassBackground()
            GlassContainer {
                VStack {
                    HStack {
                        GlassDrawToolButton(systemName: "pencil.line") {
                            toolType = .pen
                            shapeManager.tool = PenTool()
                        }
                        
                        GlassDrawToolButton(systemName: "square") { //rect
                            shapeManager.tool = RectTool()
                            toolType = .rect
                        }
                        
                        GlassDrawToolButton(systemName: "eraser") { //eraser
                            
                        }
                        
                        GlassDrawToolButton(systemName: "square.and.arrow.up") { //저장
                            shapeManager.saveShape()
                        }
                        
                        GlassDrawToolButton(systemName: "square.and.arrow.down") { //저장//복원
                            shapeManager.getShape()
                        }
                        
                        GlassDrawToolButton(systemName: "arrow.uturn.backward.circle") { //undo
                            
                        }
                        GlassDrawToolButton(systemName: "arrow.uturn.forward.circle") { //redo
                            
                        }
                        
                        GlassDrawToolButton(systemName: "t.circle") {
                            toolType = .text
                            isShowTextView.toggle()
                        }
                        
                        ColorPicker("", selection: $changedColor)
                    }
                    
                    ZStack {
                        Canvas { context, size in
                            context.withCGContext { cgContext in
                                for shape in shapeManager.shapes {
                                    shape.render(in: cgContext)
                                }
                            }
                        }
                        .simultaneousGesture(SimultaneousGesture(TapGesture(count: 1).onEnded({ _ in
                            print("tab")
                        }), DragGesture(minimumDistance: 0, coordinateSpace: .local).onChanged{ value in
                            if shapeManager.isStart {
                                shapeManager.drawStart(point: value.location)
                            } else {
                                shapeManager.drawContinue(point: value.location)
                            }
                        }.onEnded{ value in
                            shapeManager.drawEnd(point: value.location)
                        })
                        )
                        
                        if isShowTextView {
                            TextView(text: $text, rect: $textRect, isShowTextView: $isShowTextView, userSettings: shapeManager.userSettings)
                        }
                    }
                }
                .onChange(of: text) { oldValue, newValue in
                    isShowTextView = false
                    let textShape = TextShape()
                    textShape.text = text
                    textShape.boundingRect = textRect
                    textShape.apply(userSettings: shapeManager.userSettings)
                    shapeManager.addShape(shape: textShape)
                }
                .onChange(of: changedColor) { oldValue, newValue in
                    switch toolType {
                    case .pen:
                        shapeManager.userSettings.strokeColor = UIColor(newValue)
                    case .eraser:
                        print("eraser")
                    case .rect:
                        shapeManager.userSettings.strokeColor = UIColor(newValue)
                        shapeManager.userSettings.fillColor = UIColor(newValue)
                    case .text:
                        shapeManager.userSettings.strokeColor = UIColor(newValue)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 28)
        }
        .onAppear {
            if !didLoad {
                didLoad = true
                //                    shapeManager.setSize(size: proxy.size)
                shapeManager.tool = PenTool()
            }
        }
    }
}

enum ToolType {
    case pen
    case eraser
    case rect
    case text
}

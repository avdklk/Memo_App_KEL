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
    
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            
            VStack {
                HStack {
                    Button {
                        shapeManager.tool = PenTool()
                    } label: {
                        Text("펜")
                    }
                    Button {
                        shapeManager.tool = RectTool()
                    } label: {
                        Text("사각형")
                    }
                    Button {
                        let pentool = PenTool()
                        shapeManager.tool = pentool
                        pentool.setEraser(isEraser: true)
                    } label: {
                        Text("지우개")
                    }
                    Button {
                        shapeManager.saveShape()
                    } label: {
                        Text("저장")
                    }
                    Button {
                        shapeManager.getShape()
                    } label: {
                        Text("복원")
                    }
                }
                .frame(width: width, height: 50)
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
            }
            .frame(width: width, height: height)
            .onAppear {
                if !didLoad {
                    didLoad = true
                    shapeManager.setSize(size: proxy.size)
                    shapeManager.tool = PenTool()
                }
            }
        }
    }
}

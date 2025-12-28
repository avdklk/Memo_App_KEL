//
//  Untitled.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 11/23/25.
//
import SwiftUI
import CoreData

struct DrawView: View {
    @Environment(\.managedObjectContext) private var context
    @ObservedObject var note: Note
    @State private var didLoad = false
    @StateObject private var shapeManager: ShapeManager
    @State var point: CGPoint = .zero
    @State var isShowTextView: Bool = false
    @State var isShowPenWidth: Bool = false
    @State var isShowEraserWidth: Bool = false
    @State var isShowTextSize: Bool = false
    @State var text: String = ""
    @State var textRect: CGRect = .zero
    @State var changedColor: Color = .black
    @State var toolType: ToolType = .pen
    @State var strokeWidth: CGFloat = 8
    @State var fontSize: CGFloat = 15
    
    init(note: Note, context: NSManagedObjectContext) {
        self.note = note
        _shapeManager = StateObject(wrappedValue: ShapeManager(context: context, note: note))
    }
    
    var body: some View {
        
        VStack {
            HStack {
                GlassDrawToolButton(systemName: "pencil.tip") {
                    toolType = .pen
                    shapeManager.tool = PenTool()
                }
                .simultaneousGesture(LongPressGesture(minimumDuration: 0.5).onEnded({ _ in
                    isShowPenWidth.toggle()
                }))
                .popover(isPresented: $isShowPenWidth, arrowEdge: .top) {
                    Text("펜의 굵기는 \(strokeWidth, specifier: "%.2f") 입니다.")
                        .frame(width: 180)
                        .padding([.top, .trailing, .leading], 15)
                        .font(.system(size: 15))
                        .presentationCompactAdaptation(.popover)
                    
                    Slider(value: $strokeWidth, in: 1...16)
                        .padding([.trailing, .leading], 15)
                    
                    HStack {
                        Text("1")
                            .font(.system(size: 15))
                        Spacer()
                        Text("8")
                            .font(.system(size: 15))
                        Spacer()
                        Text("16")
                            .font(.system(size: 15))
                    }
                    .padding([.bottom, .trailing, .leading], 15)
                }
                
                GlassDrawToolButton(systemName: "square") { //rect
                    toolType = .rect
                    shapeManager.tool = RectTool()
                }
                
                GlassDrawToolButton(systemName: "eraser") { //eraser
                    toolType = .eraser
                    let pentool = PenTool()
                    pentool.setEraserMode(isEraser: true)
                    shapeManager.tool = pentool
                }
                .simultaneousGesture(LongPressGesture(minimumDuration: 0.5).onEnded({ _ in
                    isShowEraserWidth.toggle()
                }))
                .popover(isPresented: $isShowEraserWidth, arrowEdge: .top) {
                    Text("지우개의 굵기는 \(strokeWidth, specifier: "%.2f") 입니다.")
                        .frame(width: 180)
                        .padding([.top, .trailing, .leading], 15)
                        .font(.system(size: 15))
                        .presentationCompactAdaptation(.popover)
                    
                    Slider(value: $strokeWidth, in: 1...16)
                        .padding([.trailing, .leading], 15)
                    
                    HStack {
                        Text("1")
                            .font(.system(size: 15))
                        Spacer()
                        Text("8")
                            .font(.system(size: 15))
                        Spacer()
                        Text("16")
                            .font(.system(size: 15))
                    }
                    .padding([.bottom, .trailing, .leading], 15)
                }
                
                GlassDrawToolButton(systemName: "t.circle") {
                    toolType = .text
                    isShowTextView.toggle()
                }
                .simultaneousGesture(LongPressGesture(minimumDuration: 0.5).onEnded({ _ in
                    isShowTextSize.toggle()
                }))
                .popover(isPresented: $isShowTextSize, arrowEdge: .top) {
                    Text("텍스트 폰트 크기는 \(fontSize, specifier: "%.2f") 입니다.")
                        .frame(width: 180)
                        .padding([.top, .trailing, .leading], 15)
                        .font(.system(size: 15))
                        .presentationCompactAdaptation(.popover)
                    
                    Slider(value: $fontSize, in: 1...30)
                        .padding([.trailing, .leading], 15)
                    
                    HStack {
                        Text("1")
                            .font(.system(size: 15))
                        Spacer()
                        Text("15")
                            .font(.system(size: 15))
                        Spacer()
                        Text("30")
                            .font(.system(size: 15))
                    }
                    .padding([.bottom, .trailing, .leading], 15)
                }
               
                GlassDrawToolButton(systemName: "arrow.uturn.backward.circle") { //undo
                    shapeManager.undo()
                }
                
                GlassDrawToolButton(systemName: "arrow.uturn.forward.circle") { //redo
                    shapeManager.redo()
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
        .onChange(of:fontSize) { oldValue, newValue in
            shapeManager.userSettings.fontSize = newValue
        }
        .onChange(of: strokeWidth) { oldValue, newValue in
            shapeManager.userSettings.strokeWidth = newValue
        }
        .onChange(of: text) { oldValue, newValue in
            isShowTextView = false
            let textShape = TextShape()
            textShape.text = text
            textShape.boundingRect = textRect
            textShape.apply(userSettings: shapeManager.userSettings)
            shapeManager.addShape(shape: textShape)
            
            guard let id = UUID(uuidString: textShape.id), let type = NoteElementType(rawValue: textShape.type),  let drawingShape = textShape.getData().toData() else {return}
            
            let _ = note.addDrawingElement(in: context, id: id, data: drawingShape, type: type)
            try? context.save()
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
        .onAppear {
            if !didLoad {
                didLoad = true
                shapeManager.getShape()
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

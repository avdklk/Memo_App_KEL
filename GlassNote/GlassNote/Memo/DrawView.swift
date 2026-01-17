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
    @StateObject private var shapeManager: ShapeManager
    
    @State private var didLoad = false
    @State var showTextView: Bool = false
    @State var isShowPenWidth: Bool = false
    @State var isShowEraserWidth: Bool = false
    @State var isShowTextSize: Bool = false
    @State var text: String = ""
    @State var textRect: CGRect = .zero
    @State var changedColor: Color = .blue
    @State var toolType: ToolType = .pen
    @State private var showCamera = false
    @State private var selectedImage: UIImage?
    @State private var isPickerPresented = false
    @State private var isApplyText = false
    @State private var isScollable = true
    @State private var isScrolledToEnd = false
    @State private var isExplainSelectTool = false
    @State private var isFirstExplainSelectTool = true
    @State private var height: CGFloat = 0
    private let recognizer = TextRecognizer()
    
    init(note: Note, context: NSManagedObjectContext) {
        self.note = note
        _shapeManager = StateObject(wrappedValue: ShapeManager(context: context, note: note))
    }
    
    var body: some View {
        GeometryReader { geoProxy in
            let paperHeight = geoProxy.size.height
            
            VStack(alignment: .leading) {
                toolView
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ZStack {
                            drawingView
                            
                            if showTextView && !isScollable {
                                TextView(text: $text, rect: $textRect, isApplyText: $isApplyText,isShowTextView: $showTextView,  textWidth: $shapeManager.userSettings.fontSize, userSettings: shapeManager.userSettings)
                            }
                        }.frame(height: height)
                        
                        Color.clear
                            .frame(height: 1)
                            .onAppear {
                                withAnimation {
                                    isScrolledToEnd = true
                                }
                            }
                    }
                }
                .scrollDisabled(!isScollable)
            }
            .onChange(of: isScrolledToEnd, { oldValue, newValue in
                if newValue {
                    height += paperHeight
                    isScrolledToEnd = false
                }
            })
            .onChange(of: isApplyText) { oldValue, newValue in
                if newValue {
                    isApplyText = false
                    let textShape = TextShape()
                    textShape.text = text
                    textShape.boundingRect = textRect
                    textShape.apply(userSettings: shapeManager.userSettings)
                    shapeManager.addShape(shape: textShape)
                    shapeManager.saveNewNoteElement()
                    showTextView = false
                }
            }
            .onChange(of: showTextView) {  oldValue, newValue in
                if !newValue {
                    toolType = .pen
                    shapeManager.tool = PenTool()
                    changedColor = Color(shapeManager.userSettings.strokeColor ?? .blue)
                    text = ""
                }
            }
            .onChange(of: changedColor) { oldValue, newValue in
                switch toolType {
                case .pen:
                    shapeManager.userSettings.strokeColor = UIColor(newValue)
                case .eraser:
                    print("eraser")
                case .rect:
                    shapeManager.userSettings.fillColor = UIColor(newValue)
                case .text:
                    shapeManager.userSettings.fontColor = UIColor(newValue)
                default:
                    print("default")
                }
            }
            .onChange(of: selectedImage, { oldValue, newValue in
                shapeManager.tool = nil
                toolType = .text
                showTextView = true
                changedColor = Color(shapeManager.userSettings.fontColor)
                
                if let newValue = newValue {
                    recognizer.recognizeText(from: newValue) { text in
                        self.text = text
                    }
                }
            })
            .onAppear {
                if !didLoad {
                    didLoad = true
                    height = paperHeight
                    shapeManager.getShape()
                    toolType = .pen
                    shapeManager.tool = PenTool()
                }
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraPicker(image: $selectedImage)
                    .ignoresSafeArea()
            }
            .sheet(isPresented: $isPickerPresented) {
                PhotoPicker(image: $selectedImage)
            }
        }
    }
}

extension DrawView {
    private var toolView: some View {
        VStack(alignment: .leading, spacing: 5) {
            if isScollable {
                GlassTextButton(title: "읽기전용") {
                    isScollable = false
                }
            } else {
                GlassTextButton(title: "필기전용") {
                    isScollable = true
                }
                HStack(spacing: 3) {
                    GlassDrawToolButton(systemName: "pencil.tip", myToolType: .pen, nowToolType: toolType) {
                        toolType = .pen
                        shapeManager.tool = PenTool()
                        changedColor = Color(shapeManager.userSettings.strokeColor ?? .blue)
                        showTextView = false
                    }
                    .simultaneousGesture(TapGesture().onEnded({ _ in
                        isShowPenWidth.toggle()
                    }))
                    .tooltip(isPresented: $isShowPenWidth, title: "펜의 굵기", toSize: 25, value: $shapeManager.userSettings.strokeWidth, color: $changedColor, toolWidthArr: [3, 5, 10, 15, 25])
                    
                    GlassDrawToolButton(systemName: "square", myToolType: .rect, nowToolType: toolType) { //rect
                        toolType = .rect
                        shapeManager.tool = RectTool()
                        changedColor = Color(shapeManager.userSettings.fillColor ?? .blue)
                        showTextView = false
                    }
                    
                    GlassDrawToolButton(systemName: "eraser", myToolType: .eraser, nowToolType: toolType) { //eraser
                        toolType = .eraser
                        let pentool = PenTool()
                        pentool.setEraserMode(isEraser: true)
                        shapeManager.tool = pentool
                        showTextView = false
                    }
                    .simultaneousGesture(TapGesture().onEnded({ _ in
                        isShowEraserWidth.toggle()
                    }))
                    .tooltip(isPresented: $isShowEraserWidth, title: "지우개의 굵기", toSize: 25, value: $shapeManager.userSettings.eraserWidth, toolWidthArr: [3, 5, 10, 15, 25])
                    
                    GlassDrawToolButton(systemName: "t.circle", myToolType: .text, nowToolType: toolType) {
                        shapeManager.tool = nil
                        toolType = .text
                        showTextView.toggle()
                        changedColor = Color(shapeManager.userSettings.fontColor)
                    }
                    .simultaneousGesture(TapGesture().onEnded({ _ in
                        isShowTextSize.toggle()
                    }))
                    .tooltip(isPresented: $isShowTextSize, title: "텍스트 크기", toSize: 30, value: $shapeManager.userSettings.fontSize, color: $changedColor, toolWidthArr: [10, 15, 20, 25, 30]) {
                        HStack(alignment: .center, spacing: 10) {
                            GlassDrawToolButton(systemName: "camera", myToolType: nil, nowToolType: nil, isSelected: false) {
                                showCamera = true
                            }
                            
                            GlassDrawToolButton(systemName: "photo", myToolType: nil, nowToolType: nil, isSelected: false) {
                                isPickerPresented = true
                            }
                        }
                    }
                    
                    GlassDrawToolButton(systemName: "arrow.uturn.backward.circle", myToolType: .undo, nowToolType: toolType, isSelected: shapeManager.canUndo) { //undo
                        shapeManager.undo()
                        showTextView = false
                    }
                    
                    GlassDrawToolButton(systemName: "arrow.uturn.forward.circle", myToolType: .redo, nowToolType: toolType, isSelected: shapeManager.canRedo) { //redo
                        shapeManager.redo()
                        showTextView = false
                    }
                    
                    GlassDrawToolButton(systemName: "square.resize", myToolType: .select, nowToolType: toolType) { //select
                        
                        showTextView = false
                        let selectTool = SelectionTool()
                        toolType = .select
                        shapeManager.tool = selectTool
                    }
                    .simultaneousGesture(TapGesture().onEnded({ _ in
                        if isFirstExplainSelectTool {
                            isExplainSelectTool = true
                            isFirstExplainSelectTool = false
                        }
                    })).explainTooltip(isPresented: $isExplainSelectTool, title: "필기 위치를 바꾸는 기능입니다.")
                    
                    ColorPicker("", selection: $changedColor)
                }
            }
        }
    }
    
    private var drawingView: some View {
        Canvas { context, size in
            context.withCGContext { cgContext in
                for shape in shapeManager.shapes {
                    shape.render(in: cgContext)
                }
            }
        }
        .simultaneousGesture(SimultaneousGesture(SpatialTapGesture(count: 1).onEnded({ value in
            shapeManager.tab(point: value.location )
        }), DragGesture(minimumDistance: 0, coordinateSpace: .local).onChanged{ value in
            guard !isScollable else {
//                if !shapeManager.isStart {
//                    shapeManager.drawEnd(point: value.location)
//                }
                return
            }
            
            if shapeManager.isStart {
                shapeManager.drawStart(point: value.location)
            } else {
                shapeManager.drawContinue(point: value.location)
            }
        }.onEnded{ value in
            guard !isScollable else {return}
            shapeManager.drawEnd(point: value.location)
        })
        )
    }
}
enum ToolType {
    case pen
    case eraser
    case rect
    case text
    case undo
    case redo
    case select
    case none
}

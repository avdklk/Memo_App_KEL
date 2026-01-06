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
    @State var changedColor: Color = .blue
    @State var toolType: ToolType = .pen
    @State private var showCamera = false
    @State private var selectedImage: UIImage?
    @State private var isPickerPresented = false
    @State private var isApplyText = false
    
    private let recognizer = TextRecognizer()
    
    init(note: Note, context: NSManagedObjectContext) {
        self.note = note
        _shapeManager = StateObject(wrappedValue: ShapeManager(context: context, note: note))
    }
    
    var body: some View {
        
        VStack {
            toolView
            
            ZStack {
                drawingView
                
                if isShowTextView {
                    TextView(text: $text, rect: $textRect, isApplyText: $isApplyText,isShowTextView: $isShowTextView,  textWidth: $shapeManager.userSettings.fontSize, userSettings: shapeManager.userSettings)
                }
            }
        }
        .onChange(of: isApplyText) { oldValue, newValue in
            if newValue {
                isShowTextView = false
                isApplyText = false
                let textShape = TextShape()
                textShape.text = text
                textShape.boundingRect = textRect
                textShape.apply(userSettings: shapeManager.userSettings)
                shapeManager.addShape(shape: textShape)
                shapeManager.saveNewNoteElement()
                text = ""
            }
        }
        .onChange(of: isShowTextView) {  oldValue, newValue in
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
            isShowTextView = true
            changedColor = Color(shapeManager.userSettings.fontColor)
            
            if let image = selectedImage {
                recognizer.recognizeText(from: image) { text in
                    self.text = text
                }
            }
        })
        .onAppear {
            if !didLoad {
                didLoad = true
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

extension DrawView {
    private var toolView: some View {
        HStack {
            GlassDrawToolButton(systemName: "pencil.tip", myToolType: .pen, nowToolType: toolType) {
                toolType = .pen
                shapeManager.tool = PenTool()
                changedColor = Color(shapeManager.userSettings.strokeColor ?? .blue)
                isShowTextView = false
            }
            .simultaneousGesture(LongPressGesture(minimumDuration: 0.5).onEnded({ _ in
                isShowPenWidth.toggle()
            }))
            .widthTooltip(isPresented: $isShowPenWidth, title: "펜의 굵기", toSize: 16, value: $shapeManager.userSettings.strokeWidth)
            
            GlassDrawToolButton(systemName: "square", myToolType: .rect, nowToolType: toolType) { //rect
                toolType = .rect
                shapeManager.tool = RectTool()
                changedColor = Color(shapeManager.userSettings.fillColor ?? .blue)
                isShowTextView = false
            }
            
            GlassDrawToolButton(systemName: "eraser", myToolType: .eraser, nowToolType: toolType) { //eraser
                toolType = .eraser
                let pentool = PenTool()
                pentool.setEraserMode(isEraser: true)
                shapeManager.tool = pentool
                isShowTextView = false
            }
            .simultaneousGesture(LongPressGesture(minimumDuration: 0.5).onEnded({ _ in
                isShowEraserWidth.toggle()
            }))
            .widthTooltip(isPresented: $isShowEraserWidth, title: "지우개의 굵기", toSize: 30, value: $shapeManager.userSettings.eraserWidth)
            
            GlassDrawToolButton(systemName: "t.circle", myToolType: .text, nowToolType: toolType) {
                shapeManager.tool = nil
                toolType = .text
                isShowTextView.toggle()
                changedColor = Color(shapeManager.userSettings.fontColor)
            }
            .simultaneousGesture(LongPressGesture(minimumDuration: 0.5).onEnded({ _ in
                isShowTextSize.toggle()
            }))
            .tooltip(isPresented: $isShowTextSize, title: "텍스트 크기", toSize: 30, value: $shapeManager.userSettings.fontSize) {
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
                isShowTextView = false
            }
            
            GlassDrawToolButton(systemName: "arrow.uturn.forward.circle", myToolType: .redo, nowToolType: toolType, isSelected: shapeManager.canRedo) { //redo
                shapeManager.redo()
                isShowTextView = false
            }
            
            ColorPicker("", selection: $changedColor)
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
}
enum ToolType {
    case pen
    case eraser
    case rect
    case text
    case undo
    case redo
    case none
}

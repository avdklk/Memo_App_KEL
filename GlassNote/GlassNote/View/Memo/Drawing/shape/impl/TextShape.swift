//
//  TextShape.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 12/3/25.
//
import Foundation
import UIKit

public class TextShape: Shape, ShapeSelectable, ShapeWithBoundingRect {
    private enum CodingKeys: String, CodingKey {
        case id, transform, text, fontName, fontSize, textColor, type,
             explicitWidth, boundingRect
    }
    
    public let type = "Text"
    
    public var id: String = UUID().uuidString
    /// This shape is positioned entirely with `TextShape.transform.translate`,
    /// rather than storing an explicit position.
    public var transform: ShapeTransform = .identity
    public var text = ""
    public var fontName: String = "Helvetica Neue"
    public var fontSize: CGFloat = 14
    public var textColor = UIColor.black
    /// If user drags the text box to an exact width, we need to respect it instead
    /// of automatically sizing the text box to fit the text.
    public var explicitWidth: CGFloat?
    
    /// Set to true if this text is being shown in some other way, i.e. in a
    /// `UITextView` that the user is editing.
    public var isBeingEdited: Bool = false
    
    public var boundingRect: CGRect = .zero
    public var createdAt: Date?
    
    var font: UIFont {
        return UIFont.systemFont(ofSize: fontSize)
        //    return UIFont(name: fontName, size: fontSize)!
    }
    
    public init() {
    }
    
    public init(textData: TextData) {
        self.id = textData.id
        self.transform = textData.transform
        self.text = textData.text
        self.fontName = textData.fontName
        self.textColor = UIColor.init(hexString: textData.textColor)
        self.fontSize = textData.fontSize ?? 14
        self.explicitWidth = textData.explicitWidth
        self.boundingRect = textData.boundingRect
    }
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        let type = try values.decode(String.self, forKey: .type)
        if type != type {
            throw DrawsanaDecodingError.wrongShapeTypeError
        }
        
        id = try values.decode(String.self, forKey: .id)
        text = try values.decode(String.self, forKey: .text)
        fontName = try values.decode(String.self, forKey: .fontName)
        fontSize = try values.decode(CGFloat.self, forKey: .fontSize)
        textColor = UIColor(hexString: try values.decode(String.self, forKey: .textColor))
        explicitWidth = try values.decodeIfPresent(CGFloat.self, forKey: .explicitWidth)
        boundingRect = try values.decodeIfPresent(CGRect.self, forKey: .boundingRect) ?? .zero
        transform = try values.decode(ShapeTransform.self, forKey: .transform)
        
        if boundingRect == .zero {
            print("Text bounding rect not present. This shape will not render correctly because of a bug in Drawsana <0.10.0.")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
        try container.encode(fontName, forKey: .fontName)
        try container.encode(textColor.hexString, forKey: .textColor)
        try container.encode(fontSize, forKey: .fontSize)
        try container.encodeIfPresent(explicitWidth, forKey: .explicitWidth)
        try container.encode(transform, forKey: .transform)
        try container.encode(boundingRect, forKey: .boundingRect)
    }
    
    public func render(in context: CGContext) {
        //    if isBeingEdited { return }
        transform.begin(context: context)
        
        UIGraphicsPushContext(context)
        defer { UIGraphicsPopContext() }
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: self.fontSize) ,
            .foregroundColor: self.textColor,
        ]
        let nsText = (self.text as NSString)
        nsText.draw(
            in: boundingRect,
            withAttributes: attributes)
        transform.end(context: context)
    }
    
    public func apply(userSettings: UserSettings) {
        textColor = userSettings.fontColor 
        fontName = userSettings.fontName
        fontSize = userSettings.fontSize
    }
    
    public func getData() -> DrawingShape {
        let textData = TextData(id: id, transform: transform, text: text, fontName: fontName, textColor: textColor.hexString, explicitWidth: explicitWidth ?? 5, fontSize: fontSize, boundingRect: boundingRect)
        return DrawingShape.text(textData)
    }
}


//
//  ImageShape.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 1/24/26.
//
import Foundation
import UIKit

public class ImageShape: Shape, TransformSelectable {
    
    public var id: String = UUID().uuidString
    public var createdAt: Date?
    public var type: String = "Image"
    public var transform: ShapeTransform = .identity
    public var image: UIImage?
    
    public var boundingRect: CGRect {
        let imageWidth:CGFloat = 100
        guard let image = image else {return .zero}
        let imageRatio = image.size.height / image.size.width
        let imageHeight = imageWidth * imageRatio
        
        return CGRect(origin: .zero, size: CGSize(width: imageWidth, height: imageHeight))
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, type, transform, startP, canvasSize
    }
    
    init() {}
    init(imageData: ImageData) {
        self.id = imageData.id
        self.transform = imageData.transform
        
        if let newImage = imageData.image {
            self.image = UIImage(data: newImage)
        }
    }
    
    public required init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        let type = try values.decode(String.self, forKey: .type)
        if type != type {
            throw DrawsanaDecodingError.wrongShapeTypeError
        }
        
        id = try values.decode(String.self, forKey: .id)
        transform = try values.decode(ShapeTransform.self, forKey: .transform)
    }
    
    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(type, forKey: .type)
      try container.encode(id, forKey: .id)
        
      if !transform.isIdentity {
        try container.encode(transform, forKey: .transform)
      }
    }
    
    public func render(in context: CGContext) {
        UIGraphicsPushContext(context)
        transform.begin(context: context)
        if let myImage = image {
            myImage.draw(in: boundingRect)
        }
        transform.end(context: context)
        
        UIGraphicsPopContext()
    }
    
    public func apply(userSettings: UserSettings) {
        
    }
    
    public func getData() -> DrawingShape {
        let imageData = ImageData(id: id, transform: transform, image: image?.pngData())
        return .image(imageData)
    }
    
}

//
//  ImageTool.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 1/24/26.
//
import UIKit

class ImageTool: TransformDrawingTool {
    public override var name: String { return "Image" }
    public override func makeShape() -> TransformSelectable? {
        guard let image = image else {return nil}
        let imageShape = ImageShape()
        imageShape.image = image
        return imageShape
    }
    
    private let image: UIImage?
    init(image: UIImage?) {
        self.image = image
    }

    
    
}

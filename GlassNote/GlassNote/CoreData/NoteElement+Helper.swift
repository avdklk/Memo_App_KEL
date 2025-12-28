//
//  NoteElement+Helper.swift
//  GlassNote
//
//  Created by jyh on 12/19/25.
//

import Foundation
import CoreData

//MARK: - NoteElement 타입 정의
enum NoteElementType: String {
    case text = "Text"
    case rect = "Rectangle"
    case pen = "Pen"
}

//MARK: - NoteElement 헬퍼 메서드
extension NoteElement {
    var shape: DrawingShape? {
        get {
            guard let data = self.drawingShape else {return nil}
            do {
                return try JSONDecoder().decode(DrawingShape.self, from: data)
            } catch {
                print("디코딩 실패: \(error)")
                return nil
            }
        }
        set {
            guard let newValue = newValue else { return }
            do {
                let data = try JSONEncoder().encode(newValue)
                self.drawingShape = data
                
                switch newValue {
                case .pen: self.type = "pen"
                case .rect: self.type = "rect"
                case .text: self.type = "text"
                }
            } catch {
                print("디코딩 실패: \(error)")
            }
        }
    }
    /// 스케치/드로잉 요소 생성 (PencilKit 등)
    static func createDrawing(
        in context: NSManagedObjectContext,
        id: UUID,
        note: Note,
        data: Data,
        type: NoteElementType = .pen,
    ) -> NoteElement {
        let element = NoteElement(context: context)
        element.id = id
        element.type = type.rawValue
        element.drawingShape = data
        element.createdAt = Date()
        element.note = note
        return element
    }
    
    /// 요소 타입 확인
    var elementType: NoteElementType? {
        guard let type = type else {return nil}
        return NoteElementType(rawValue: type)
    }

}

//MARK: - Note 헬퍼 메서드
extension Note {
    
    /// 정렬된 요소 배열 반환
    var sortedElements: [NoteElement] {
        let set = elements as? Set<NoteElement> ?? []
        return set.filter{ $0.createdAt != nil }.sorted { $0.createdAt! < $1.createdAt! }
    }
    
    var shapes: [Shape] {
        var shapes: [Shape] = []
        for e in sortedElements {
            switch e.shape {
            case .pen(let penData):
                let penShape = PenShape(penData: penData)
                shapes.append(penShape)
            case .rect(let rectData):
                let rectShape = RectShape(rectData: rectData)
                shapes.append(rectShape)
            case .text(let textData):
                let textShape = TextShape(textData: textData)
                shapes.append(textShape)
            case .none:
                print("Note shapes type 없음")
            }
        }
        return shapes
    }
    /// 다음 순서 번호 반환
    var nextElementId: UUID? {
        let maxOrder = sortedElements.last?.id
        return maxOrder
    }
    
    /// 드로잉 요소 추가
    func addDrawingElement(in context: NSManagedObjectContext,id: UUID, data: Data, type: NoteElementType = .pen) -> NoteElement {
        return NoteElement.createDrawing(
            in: context,
            id: id,
            note: self,
            data: data,
            type: type
        )
    }
}

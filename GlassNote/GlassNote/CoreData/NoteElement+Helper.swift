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
    case text = "text"
    case sketch = "sketch"
    case drawing = "drawing"
}

//MARK: - NoteElement 헬퍼 메서드
extension NoteElement {
    
    /// 텍스트 요소 생성
    static func createText(
        in context: NSManagedObjectContext,
        note: Note,
        content: String,
        order: Int16
    ) -> NoteElement {
        let element = NoteElement(context: context)
        element.id = UUID()
        element.type = NoteElementType.text.rawValue
        element.textContent = content
        element.order = order
        element.createdAt = Date()
        element.note = note
        return element
    }
    
    /// 스케치/드로잉 요소 생성 (PencilKit 등)
    static func createDrawing(
        in context: NSManagedObjectContext,
        note: Note,
        data: Data,
        type: NoteElementType = .sketch,
        order: Int16
    ) -> NoteElement {
        let element = NoteElement(context: context)
        element.id = UUID()
        element.type = type.rawValue
        element.drawingData = data
        element.order = order
        element.createdAt = Date()
        element.note = note
        return element
    }
    
    /// 요소 타입 확인
    var elementType: NoteElementType? {
        guard let type = type else { return nil }
        return NoteElementType(rawValue: type)
    }
    
    /// 텍스트 타입인지 확인
    var isText: Bool {
        return elementType == .text
    }
    
    /// 드로잉 타입인지 확인
    var isDrawing: Bool {
        return elementType == .sketch || elementType == .drawing
    }
}

//MARK: - Note 헬퍼 메서드
extension Note {
    
    /// 정렬된 요소 배열 반환
    var sortedElements: [NoteElement] {
        let set = elements as? Set<NoteElement> ?? []
        return set.sorted { $0.order < $1.order }
    }
    
    /// 다음 순서 번호 반환
    var nextElementOrder: Int16 {
        let maxOrder = sortedElements.last?.order ?? -1
        return maxOrder + 1
    }
    
    /// 텍스트 요소 추가
    func addTextElement(in context: NSManagedObjectContext, content: String) -> NoteElement {
        return NoteElement.createText(
            in: context,
            note: self,
            content: content,
            order: nextElementOrder
        )
    }
    
    /// 드로잉 요소 추가
    func addDrawingElement(in context: NSManagedObjectContext, data: Data, type: NoteElementType = .sketch) -> NoteElement {
        return NoteElement.createDrawing(
            in: context,
            note: self,
            data: data,
            type: type,
            order: nextElementOrder
        )
    }
}

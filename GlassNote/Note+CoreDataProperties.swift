//
//  Note+CoreDataProperties.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 12/21/25.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var previewText: String?
    @NSManaged public var title: String?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var elements: NSSet?

}

// MARK: Generated accessors for elements
extension Note {

    @objc(addElementsObject:)
    @NSManaged public func addToElements(_ value: NoteElement)

    @objc(removeElementsObject:)
    @NSManaged public func removeFromElements(_ value: NoteElement)

    @objc(addElements:)
    @NSManaged public func addToElements(_ values: NSSet)

    @objc(removeElements:)
    @NSManaged public func removeFromElements(_ values: NSSet)

}

extension Note : Identifiable {

}

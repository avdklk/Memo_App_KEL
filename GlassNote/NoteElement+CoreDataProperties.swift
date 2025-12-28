//
//  NoteElement+CoreDataProperties.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 12/21/25.
//
//

import Foundation
import CoreData


extension NoteElement {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NoteElement> {
        return NSFetchRequest<NoteElement>(entityName: "NoteElement")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var drawingShape: Data?
    @NSManaged public var id: UUID?
    @NSManaged public var type: String?
    @NSManaged public var note: Note?

}

extension NoteElement : Identifiable {

}

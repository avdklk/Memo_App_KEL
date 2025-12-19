//
//  PersistenceController.swift
//  GlassNote
//
//  Created by jyh on 11/28/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "GlassNote")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("Core Data failed to load: \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    // Preview용
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext
        
        // 샘플 데이터 생성
        for i in 0..<3 {
            let note = Note(context: context)
            note.id = UUID()
            note.title = "Sample Note \(i + 1)"
            note.previewText = "This is a preview text for note \(i + 1)"
            note.updatedAt = Date()
        }
        
        try? context.save()
        return controller
    }()
}

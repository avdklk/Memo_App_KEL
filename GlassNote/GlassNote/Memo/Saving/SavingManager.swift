//
//  SavingManager.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 11/28/25.
//

import Foundation

class SavingManager {
    var fileURL: URL {
        let docDir = FileManager.default.urls(for: .documentDirectory,
                                              in: .userDomainMask).first!
        return docDir.appendingPathComponent("shapes.json")
      }
    
    func save(drawing: Drawing) throws {
        let encoder = JSONEncoder()
            let data = try encoder.encode(drawing)
            try data.write(to: fileURL, options: .atomic)
      }
    
    func loadShapes() throws -> Drawing {
       let data = try Data(contentsOf: fileURL)
       let decoder = JSONDecoder()
       return try decoder.decode( Drawing.self, from: data)
     }
}

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
        /*
         po data
        ▿ 291 bytes
          - count : 291
          ▿ pointer : 0x000000010a405840
            - pointerValue : 4466956352
         */
            try data.write(to: fileURL, options: .atomic)
      }
    
    func loadShapes() throws -> Drawing {
       let data = try Data(contentsOf: fileURL)
        /*
         po data
         ▿ 291 bytes
           - count : 291
           ▿ pointer : 0x0000000109f32960
             - pointerValue : 4461898080
         */
       let decoder = JSONDecoder()
       return try decoder.decode( Drawing.self, from: data)
     }
}

//
//  Dictionary_ext.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 2/5/26.
//
import Foundation

extension Dictionary {
    func toModel<T: Decodable>(_ type: T.Type) -> T? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: [])
            let model = try JSONDecoder().decode(T.self, from: jsonData)
            return model
        } catch {
            print("--- 변환 실패: \(error.localizedDescription) ---")
            return nil
        }
    }
}

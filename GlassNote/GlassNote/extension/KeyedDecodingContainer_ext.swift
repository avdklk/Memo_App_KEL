//
//  KeyedDecodingContainer_ext.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 12/4/25.
//

import UIKit

extension KeyedDecodingContainer {
  func decodeColorIfPresent(forKey key: K) throws -> UIColor? {
    guard let hexString = try decodeIfPresent(String.self, forKey: key) else { return nil }
    return UIColor(hexString: hexString)
  }
}

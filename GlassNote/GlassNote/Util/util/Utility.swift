//
//  Utility.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 2/11/26.
//

import Foundation

class Utility {
    static var bundleID: String {
        return Bundle.main.bundleIdentifier ?? KeyConstants.AppInfo.bundleId.rawValue
    }
}

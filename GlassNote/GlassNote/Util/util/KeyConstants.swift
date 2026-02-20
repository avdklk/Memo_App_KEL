//
//  KeyConstant.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 2/11/26.
//

enum KeyConstants {
    enum AppInfo: String {
        case bundleId = "team.GlassLab.GlassNote"
    }
    
    enum Keychain: String {
        case userInfo = "GlassNote"
    }
    
    enum UserDefaults: String {
        case appleIdentifier = "appleIdentifier"
    }
}

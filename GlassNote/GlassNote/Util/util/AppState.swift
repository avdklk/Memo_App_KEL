//
//  AppState.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 2/18/26.
//

import Foundation
import SwiftUI

@MainActor
class AppState: ObservableObject {
    static let instance = AppState()
    @Published var currentView: ViewType = .start
    @Published var subState: Bool = false
    
    enum ViewType {
        case start, fileSelect, login, transaction
    }
    
    private init() {
        StorageUtil.instance.checkSubStatus{ [weak self] isSub in
            self?.subState = isSub
        }
    }
}

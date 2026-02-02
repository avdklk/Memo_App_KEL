//
//  GlassNoteApp.swift
//  GlassNote
//
//  Created by jyh on 11/17/25.
//

import SwiftUI

@main
struct GlassNoteApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    let persistenceController = PersistenceController.shared
    @StateObject private var transactionManager = TransactionManager.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(transactionManager)
        }
    }
}

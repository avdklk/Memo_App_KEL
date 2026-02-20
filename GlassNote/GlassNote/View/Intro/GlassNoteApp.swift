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
    @StateObject var appState = AppState.instance
    @StateObject var networkMonitor = NetworkMonitor.shared
    
    var body: some Scene {
        WindowGroup {
            switch appState.currentView {
            case .start:
                ContentView()
                    .environmentObject(appState)
            case .fileSelect:
                FileSelete()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(appState)
                    .environmentObject(networkMonitor)
            case .login:
                LoginView()
                    .environmentObject(appState)
                    .environmentObject(networkMonitor)
            case .transaction:
                TransactionView()
                    .environmentObject(appState)
                    .environmentObject(networkMonitor)
            }
        }
    }
}

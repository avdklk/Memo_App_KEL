//
//  AppDelegate.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 2/2/26.
//

import FirebaseCore
import UIKit


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    NetworkMonitor.shared.startMonitoring()
    return true
  }
}

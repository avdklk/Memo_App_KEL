//
//  PersistenceController.swift
//  GlassNote
//
//  Created by jyh on 11/28/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentCloudKitContainer
    
    init() {
        container = NSPersistentCloudKitContainer(name: "GlassNote")
        setupContainer()
    }
    
    func setupContainer() {
        for store in container.persistentStoreCoordinator.persistentStores {
            try? container.persistentStoreCoordinator.remove(store)
        }
        
        guard let description = container.persistentStoreDescriptions.first else { return }
        
        // UserDefaults에서 사용자의 iCloud 사용 여부를 가져옴 (기본값 true)
        let isCloudEnabled = UserDefaults.standard.bool(forKey: KeyConstants.UserDefaults.icloud.rawValue)
        
        if isCloudEnabled {
            // iCloud 활성화
            description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.team.GlassLab.GlassNote")
            description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        } else {
            // iCloud 비활성화 (로컬 모드)
            description.cloudKitContainerOptions = nil
            // 로컬 모드에서도 히스토리 트래킹은 켜두는 것이 안전합니다.
            description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        }
        
        // 설정 변경 후 스토어 다시 로드
        container.loadPersistentStores { (description, error) in
            if let error = error as NSError? {
                print("Error loading store: \(error)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}

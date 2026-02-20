//
//  KeyChainHelper.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 2/9/26.
//
import Foundation
import Security

class KeychainHelper {
    
    static let instance = KeychainHelper()
    private init() {}
    
    // MARK: - 1. 저장 및 수정 (Upsert)
    /// 데이터를 저장합니다. 만약 이미 존재하는 키라면 자동으로 업데이트합니다.
    func save(data: Data, service: String, account: String) -> Bool {
        
        // 1. 저장할 데이터 쿼리 생성
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,//비밀번호, 토큰 저장
            kSecAttrService as String: service, // 앱 번들 ID
            kSecAttrAccount as String: account,// 저장할 데이터의 이름
            kSecValueData as String: data
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecSuccess {
            return true
        } else if status == errSecDuplicateItem {
            // 4. 이미 존재함(Duplicate) -> 업데이트 시도
            let queryToSearch: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account
            ]
            
            let attributesToUpdate: [String: Any] = [
                kSecValueData as String: data
            ]
            
            let updateStatus = SecItemUpdate(queryToSearch as CFDictionary, attributesToUpdate as CFDictionary)
            return updateStatus == errSecSuccess
            
        } else {
            // 기타 에러
            print("Keychain Save Error: \(status)")
            return false
        }
    }
    
    // MARK: - 2. 조회 (Read)
    func read(service: String, account: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        if status == errSecSuccess {
            return item as? Data
        }
        return nil
    }
    
    // MARK: - 3. 삭제 (Delete)
    func delete(service: String, account: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}

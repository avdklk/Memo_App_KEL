//
//  StorageManager.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 2/4/26.
//
import FirebaseAuth
import FirebaseFirestore

class StorageManager {
    static let instance = StorageManager()
    
    //collection
    private let SUBSCRIBE = "SUBSCRIBE"
    private let USER = "USER"
    
    private let db = Firestore.firestore()
    
    private init() {
        let _ = Auth.auth().currentUser
    }
    
    func addSubscriberData(userID: String, subscriber: SubscribeData) {
        let data: [String: Any] = [
            "Date": subscriber.Date,
            "Key": subscriber.Key,
            "Month": subscriber.Month,
            "Year": subscriber.Year
        ]
        
        db.collection(SUBSCRIBE).document(userID).setData(data) { result in
            if let error = result?.localizedDescription {
                print("addSubscriberData Error: \(error)")
            }
        }
    }

    func loadSubscriberData(userID: String, complete: @escaping (SubscribeData?) -> Void) {
        let reference = db.collection(SUBSCRIBE).document(userID)
        
        reference.getDocument { document, error in
            if let rawData = document?.data() {
                complete(rawData.toModel(SubscribeData.self))
            } else {
                complete(nil)
            }
        }
    }

    func deleteDocument(userID: String) {
        db.collection(SUBSCRIBE).document(userID).delete { error in
            if let error = error {
                print("Error removing document: \(error.localizedDescription)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
    
    func addUserInfo(userID: String, userInfo: UserInfoData) async {
        let data: [String: Any] = [
            "Email": userInfo.Email,
            "Name": userInfo.Name
        ]
        
        do {
            try await db.collection(USER).document(userID).setData(data)
            print("Successfully saved user info.")
        } catch {
            print("addUserInfo Error: \(error)")
        }
    }

    func loadUserInfo(userID: String) async -> UserInfoData? {
        let reference = db.collection(USER).document(userID)
        
        do {
            let document = try await reference.getDocument()
            let rawData = document.data()
            return rawData?.toModel(UserInfoData.self)
        } catch {
            print("Error getting user document: \(error.localizedDescription)")
            return nil
        }
    }
    
    func signOut() -> Bool {
        do {
            try Auth.auth().signOut()
            return true
        } catch let signOutError as NSError {
            print("로그아웃 오류: \(signOutError.localizedDescription)")
            return false
        }
    }
}

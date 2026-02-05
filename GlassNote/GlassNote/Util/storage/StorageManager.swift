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
    private let USER = "USER"
    
    
    
    let db = Firestore.firestore()
    
    func addSubscriberData(userID: String, subscriber:SubscribeData) {
        db.collection(USER).document(userID).setData(["Date": subscriber.Date,
                                                 "Key": subscriber.Key,
                                                 "Month": subscriber.Month,
                                                 "Year": subscriber.Year]) { error in
            if let error = error {
                print("There was an issue saving data to firestore, \(error)")
            } else {
                print("Successfully saved data.")
            }
        }
    }
    
    func loadSubscriberData(userID: String, complete:@escaping (SubscribeData?) -> Void) {
        let reference = db.collection(USER).document(userID)
        reference.getDocument { querySnapshot, err in
            guard let document = querySnapshot else {
                print("Error getting documents: \(err?.localizedDescription ?? "nil")")
                return
            }
            let rawData = document.data()
            let subscribeData = rawData?.toModel(SubscribeData.self)
            complete(subscribeData)
        }
    }
}

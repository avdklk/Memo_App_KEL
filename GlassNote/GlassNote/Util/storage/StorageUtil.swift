//
//  StorageUtil.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 2/11/26.
//

import Foundation

class StorageUtil {
    static let instance = StorageUtil()
    
    private init() {}
    
    func checkSubStatus(complate: @escaping (Bool) -> Void) {
        guard let appleIdentifier = UserDefaults.standard.string(forKey: KeyConstants.UserDefaults.appleIdentifier.rawValue) else { return complate(false) }
        
        StorageManager.instance.loadSubscriberData(userID: appleIdentifier) { [weak self] subData in
            
            if let self = self, let subscribeDate = subData?.Date {
                let result = verifySubscribedDate(subscribeDate: subscribeDate)
                complate(result)
            } else {
                complate(false)
            }
        }
    }
    
    func saveSubData(subscribeData: SubscribeData) {
        
    }
    
    func endSubscribe() {
        
    }
    
    func verifySubscribedDate(subscribeDate: String) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        
        // 5. 변환 (결과는 Optional Type인 Date? 입니다)
        if let date = formatter.date(from: subscribeDate) {
            print("변환 성공: \(date)")
            return date >= Date()
        } else {
            print("변환 실패: 포맷이 맞지 않습니다.")
            return false
        }
    }
    
    func stringToDate(date: String, dateForamt: String = "yyyyMMdd") -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = dateForamt

        guard let newDate = formatter.date(from: date) else {return nil}

        return newDate
    }
    
    func dateToString(date: Date, dateFormat:String = "yyyyMMdd") -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")

        // 5. 변환 (결과는 Optional Type인 Date? 입니다)
        let dateString = formatter.string(from: date)
        return dateString
    }
    
    func mergeSubscriptionDates(month: Bool, year: Bool) -> String? {
        let calendar = Calendar.current
        let now = Date()
        
        var remainingDays = 0
        if month {
            remainingDays = 30
        }
        
        if year {
            remainingDays = 365
        }
        
        guard let newExpiryDate = calendar.date(byAdding: .day, value: remainingDays, to: now) else {return nil}
        
        let newDate = dateToString(date: newExpiryDate)
        return newDate
    }
}

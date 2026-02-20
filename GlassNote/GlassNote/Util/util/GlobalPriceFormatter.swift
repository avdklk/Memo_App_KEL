//
//  GlobalPriceFormatter.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 2/1/26.
//
import Foundation

class GlobalPriceFormatter {
    static func format(price: Double, currencyCode: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.locale = Locale.current
        
        return formatter.string(from: NSNumber(value: price)) ?? "\(price)"
    }
}

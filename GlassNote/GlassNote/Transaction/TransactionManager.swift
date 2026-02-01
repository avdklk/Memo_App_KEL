//
//  TransactionManager.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 1/27/26.
//
import Foundation
import StoreKit
import SwiftUI // ObservableObject를 위해 필요

// UI 업데이트를 보장하기 위해 MainActor 적용
@MainActor
class TransactionManager: ObservableObject {
    
    static let shared = TransactionManager()
    
    // 제품 ID 목록 (실제 앱에서는 Configuration 파일 등에서 관리 권장)
    private let productIds = ["Month_Sub_Kelee", "Year_Sub_Kelee"]
    
    @Published private(set) var productDict: [String : Product] = [:]
    @Published private(set) var purchasedProductIDs = Set<String>()
    @Published var isLoading: Bool = false
    
    private var productsLoaded = false
    private var updatesTask: Task<Void, Never>? = nil
    
    var hasUnlockedPro: Bool {
        return !self.purchasedProductIDs.isEmpty
    }
    
    private init() {
        // 클래스 초기화 시 트랜잭션 감시 시작
        startObservingTransactionUpdates()
        
        // 앱 실행 시 기존 구매 내역(Entitlements) 확인
        Task {
            await updateCurrentEntitlements()
        }
    }
    
    // MARK: - 제품 불러오기
    func loadProducts() async {
        guard !self.productsLoaded else { return }
        
        do {
            let products = try await Product.products(for: productIds)
            
            var newProductDict: [String: Product] = [:]
            for product in products {
                newProductDict[product.id] = product
            }
            
            self.productDict = newProductDict
            self.productsLoaded = true
        } catch {
            print("Failed to load products: \(error)")
        }
    }
    
    // MARK: - 구매 요청
    func purchase(_ product: Product) async throws {
        self.isLoading = true
        // defer: 함수가 종료될 때 무조건 실행 (로딩 종료)
        defer { self.isLoading = false }
        
        let result = try await product.purchase()
        
        switch result {
        case let .success(.verified(transaction)):
            // 구매 성공 및 검증 완료
            await transaction.finish()
            await self.updatePurchasedProducts(transaction: transaction)
            
        case let .success(.unverified(_, error)):
            // 구매는 성공했으나 애플 검증 실패
            print("Unverified transaction: \(error)")
            throw error
            
        case .pending:
            // 승인 대기 중 (부모님 승인 요청 등)
            print("Transaction pending")
            
        case .userCancelled:
            // 사용자 취소
            print("User cancelled")
            
        @unknown default:
            break
        }
    }
    
    // MARK: - 구독 버튼 탭 (뷰에서 호출하는 함수)
    func subscribeButtonTapped(selectedButton: String) {
        var selectedProductId = ""
        
        switch selectedButton {
        case "yearly":
            selectedProductId = "Year_Sub_Kelee"
        case "monthly":
            selectedProductId = "Month_Sub_Kelee"
        default:
            print("Invalid selection")
            return
        }
        
        guard let wishProduct = productDict[selectedProductId] else {return}
        // 비동기 구매 실행
        Task {
            do {
                try await self.purchase(wishProduct)
            } catch {
                print("Purchase failed: \(error)")
            }
        }
    }
    
    // MARK: - 트랜잭션 업데이트 처리 (핵심 로직)
    func updatePurchasedProducts(transaction: StoreKit.Transaction) async {//Q Transaction -> StoreKit.Transaction
        // 1. 거래가 취소(환불)된 경우
        if transaction.revocationDate != nil {
            self.purchasedProductIDs.remove(transaction.productID)
            return
        }
        
        // 2. 만료된 경우 (구독이 끝남)
        if let expirationDate = transaction.expirationDate, expirationDate < Date() {
            self.purchasedProductIDs.remove(transaction.productID)
            return
        }
        
        // 3. 업그레이드 된 경우 (상위 구독으로 변경됨 -> 현재 트랜잭션은 무시)
        if transaction.isUpgraded {
            self.purchasedProductIDs.remove(transaction.productID)
            return
        }
        
        // 4. 유효한 구매 내역인 경우 -> Set에 추가
        self.purchasedProductIDs.insert(transaction.productID)
    }
    
    // MARK: - 앱 시작 시 기존 권한(Entitlements) 확인
    // 앱을 재설치하거나 다시 켰을 때 내가 산 항목이 있는지 확인하는 필수 함수
    private func updateCurrentEntitlements() async {
        for await result in Transaction.currentEntitlements {
            if case let .verified(transaction) = result {
                await self.updatePurchasedProducts(transaction: transaction)
            }
        }
    }
    
    // MARK: - 실시간 트랜잭션 감시 (App Store에서 발생하는 외부 이벤트 감지)
    func startObservingTransactionUpdates() {
        updatesTask = Task(priority: .background) { [weak self] in
            for await update in Transaction.updates {
                guard let self = self else { return }
                
                if case let .verified(transaction) = update {
                    await transaction.finish()
                    await self.updatePurchasedProducts(transaction: transaction)
                }
            }
        }
    }
    
    func stopObservingTransactionUpdates() {
        updatesTask?.cancel()
        updatesTask = nil
    }
    
    func getPrice(selectedButton: String) -> String? {
        var selectedProductId = ""
        
        switch selectedButton {
        case "yearly":
            selectedProductId = "Year_Sub_Kelee"
        case "monthly":
            selectedProductId = "Month_Sub_Kelee"
        default:
            print("Invalid selection")
            return nil
        }
        
        guard let wishProduct = productDict[selectedProductId] else {return nil}
        
        let code = wishProduct.priceFormatStyle.currencyCode
        
        return GlobalPriceFormatter.format(price: NSDecimalNumber(decimal:wishProduct.price).doubleValue, currencyCode: code)
    }
    
    func calculateYearlySavings() -> String? {
        guard let monthly = productDict["Month_Sub_Kelee"], let yearly = productDict["Year_Sub_Kelee"] else {return nil}
        // 1. 월간 가격을 1년치로 환산 (월간 가격 * 1
        let monthlyPrice = monthly.price
        let annualizedMonthlyPrice = monthlyPrice * 12
        
        // 2. 연간 가격
        let yearlyPrice = yearly.price
        
        // 방어 코드: 연간 가격이 더 비싸면 할인 문구 없음
        guard annualizedMonthlyPrice > yearlyPrice else { return nil }
        
        // 3. 할인율 계산 공식: ((원래가격 - 할인가격) / 원래가격) * 100
        let savings = annualizedMonthlyPrice - yearlyPrice
        
        let savingsValue = NSDecimalNumber(decimal: savings).doubleValue
        let totalValue = NSDecimalNumber(decimal: annualizedMonthlyPrice).doubleValue

        // 2. Double로 계산하고 Int로 변환
        // (5800.0 / 10000.0) * 100.0  => 58.0
        // Int(58.0) => 58
        let percentInt = Int((savingsValue / totalValue) * 100)
        
        return "\(percentInt)%"
    }
}

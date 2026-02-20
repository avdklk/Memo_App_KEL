//
//  TransactionView.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 1/28/26.
//
import StoreKit
import SwiftUI

struct TransactionView: View {
    @StateObject var transactionManager: TransactionManager = TransactionManager.instance
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    @State private var showAlert = false
    @State private var title: String = ""
    @State private var message: String = ""
    @State private var showNetworkPopup: Bool = false
    
    var body: some View {
        ZStack {
            GlassBackground()
            VStack {
                HStack {
                    Spacer()
                    GlassDrawToolButton(systemName: "x.circle.fill", myToolType: nil) {
                        appState.currentView = .fileSelect
                    }
                }
                VStack(spacing: 12) {
                    Image(systemName: "pencil.and.scribble")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text("GlassNote")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("Subscribe")
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("Create more memos with Premium.")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 28)
                
                ClearContainer {
                    VStack(spacing: 8) {
                        Text("더 넓어진 기록의 공간")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(.white)
                        
                        Text("이제 개수 걱정 없이 마음껏 메모장을 만드세요.")
                            .font(.system(size: 18, weight: .regular))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                        
                        Text("완벽한 iCloud 동기화 지원.\n모든 애플 기기가 하나처럼 연결됩니다.")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("무제한 메모장 생성은 프리미엄 기능입니다.")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(.white)
                    }
                }
                .padding(20)
                
                Button(action: {
                    if networkMonitor.isConnected {
                        transactionManager.subscribeButtonTapped(selectedButton:"monthly")
                    }
                }, label: {
                    GlassContainer {
                        HStack(spacing: 15) {
                            Text("1 Month")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                            
                            Text("\(transactionManager.getPrice(selectedButton: "monthly") ?? "nil")")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }.frame(height: 50)
                })
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                
                Button(action: {
                    if networkMonitor.isConnected {
                        transactionManager.subscribeButtonTapped(selectedButton:"yearly")
                    }
                }, label: {
                    GlassContainer {
                        HStack(spacing: 15) {
                            Spacer()
                            
                            Text("1 Year")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                            
                            Text("\(transactionManager.getPrice(selectedButton: "yearly") ?? "nil")")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(.white)
                            
                            Text("SAVE \(transactionManager.calculateYearlySavings() ?? "nil")")
                                .font(.caption.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.red)
                                .cornerRadius(8)
                        }
                    }.frame(height: 50)
                })
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                
                Button(action: {
                    if networkMonitor.isConnected {
                        Task {
                            await transactionManager.restorePurchases()
                        }
                    }
                }, label: {
                    Text("구매 내역 복구")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding()
                })
                
            }
        }
        .alert("알림", isPresented: $showNetworkPopup) {
            Button("확인", role: .none) { }
        } message: {
            Text("네트워크 연결을 확인해 주세요.")
        }
        .onAppear {
            Task {
                await transactionManager.loadProducts()
            }
            showNetworkPopup = !networkMonitor.isConnected
        }
        .onChange(of: networkMonitor.isConnected) { oldValue, newValue in
            showNetworkPopup = !newValue
        }
        .onChange(of: transactionManager.purchasedProductIDs) { oldValue, newValue in
            if newValue.count > 0 {
                appState.currentView = .fileSelect
            }
        }
    }
}

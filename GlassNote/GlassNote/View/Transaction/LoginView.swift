//
//  LoginView.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 2/5/26.
//
import AuthenticationServices
import FirebaseCore
import SwiftUI
import _AuthenticationServices_SwiftUI
import FirebaseAuth

struct LoginView: View {
    @EnvironmentObject var transactionManager: TransactionManager
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var networkMonitor: NetworkMonitor

    @State private var currentNonce: String?
    @State private var showNetworkPopup: Bool = false
    
    var body: some View {
        ZStack {
            GlassBackground()
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        appState.currentView = .fileSelect
                    }, label: {
                        Image(systemName: "xmark")
                            .scaledToFill()
                            .foregroundStyle(.white)
                            .frame(width: 30, height: 30)
                    })
                    .padding(.trailing, 10)
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
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 28)
                
                VStack(spacing: 12) {
                    BenefitRow(icon: "infinity", title: "무제한 메모장", description: "기본 1장의 제한 없이 마음껏 만드세요.")
                        .frame(height: 100)
                    
                    BenefitRow(icon: "ipad.landscape.and.iphone", title: "기기 간 동기화", description: "아이폰과 아이패드에서 구독권을 공유하세요.")
                        .frame(height: 100)
                    
                    BenefitRow(icon: "cloud.fill", title: "안전한 데이터", description: "로그인으로 소중한 메모를 안전하게 보관하세요.")
                        .frame(height: 100)
                }
                .padding(.horizontal, 20)
                
                VStack(spacing: 15) {
                    Text("구독 정보 저장과 복원을 위해 Apple 로그인이 필요합니다.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding()
                    
                    SignInWithAppleButton(
                        onRequest: { request in
                            let nonce = NonceManager().randomNonceString()
                            currentNonce = nonce
                            
                            request.requestedScopes = [.fullName, .email]
                            request.nonce = NonceManager().sha256(nonce)
                        },
                        onCompletion: { result in
                            switch result {
                            case .success(let authResults):
                                handleAuthorization(authResults)
                            case .failure(let error):
                                print("로그인 실패: \(error.localizedDescription)")
                            }
                        }
                    )
                    .signInWithAppleButtonStyle(.black)
                    .cornerRadius(15)
                    .frame(height: 45)
                    .padding(.horizontal, 20)
                }
            }
        }.alert("알림", isPresented: $showNetworkPopup) {
            Button("확인", role: .none) { }
        } message: {
            Text("네트워크 연결을 확인해 주세요.")
        }
        .onChange(of: networkMonitor.isConnected) { oldValue, newValue in
            showNetworkPopup = newValue
        }
        .onAppear {
            showNetworkPopup = !networkMonitor.isConnected
        }
    }
    
    func handleAuthorization(_ authorization: ASAuthorization) {
        guard networkMonitor.isConnected,
              let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
        
        guard let nonce = currentNonce else {
            fatalError("Invalid state: A login callback was received, but no login request was sent.")
        }
        
        guard let appleIDToken = appleIDCredential.identityToken else {
            print("Unable to fetch identity token")
            return
        }
        
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
            return
        }
        
        let credential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nonce,
            fullName: appleIDCredential.fullName)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print("Firebase 로그인 실패: \(error.localizedDescription)")
                return
            }
            
            //                if let user = authResult?.user {
            if let fullName = appleIDCredential.fullName {
                let name = "\(fullName.givenName ?? "") \(fullName.familyName ?? "")"
                print("사용자 이름: \(name)")
                
                if let email = appleIDCredential.email,
                   let infoData = try? JSONEncoder().encode(UserInfoData(Email: email, Name: name)) {
                    let _ = KeychainHelper.instance.save(data: infoData, service: Utility.bundleID, account: KeyConstants.Keychain.userInfo.rawValue)
                    
                    Task {
                        await StorageManager.instance.addUserInfo(userID: appleIDCredential.user, userInfo: UserInfoData(Email: email, Name: name))
                    }
                }
            }
            //                }
            // 여기에 키체인에서 가져와서 유저 인포 통신하는 코드 만들기
            UserDefaults.standard.set(appleIDCredential.user, forKey: KeyConstants.UserDefaults.appleIdentifier.rawValue)
            
            changeNextView()
        }
    }
    
    private func changeNextView() {
        if !transactionManager.hasUnlockedPro && !appState.subState {
            appState.currentView = .transaction
        } else {
            appState.currentView = .fileSelect
        }
    }
}


struct BenefitRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        ClearContainer {
            HStack(alignment: .top, spacing: 15) {
                Image(systemName: icon)
                    .foregroundColor(.black)
                    .padding([.top, .leading], 4)
                    .frame(width: 30, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.black)
                }
                Spacer()
            }
        }
    }
}

#Preview {
    LoginView()
}

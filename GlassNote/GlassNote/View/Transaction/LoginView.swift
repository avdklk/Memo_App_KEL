//
//  LoginView.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 2/5/26.
//
import SwiftUI
import _AuthenticationServices_SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            GlassBackground()
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        dismiss()
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
                    
                    Text("Create more memos with Premium.")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.8))
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
                    
                    // Apple 로그인 버튼
                    SignInWithAppleButton(
                        // 1. 어떤 정보를 요청할 것인가?
                        onRequest: { request in
                            request.requestedScopes = [.fullName, .email]
                        },
                        // 2. 결과 처리 (성공/실패)
                        onCompletion: { result in
                            switch result {
                            case .success(let authResults):
                                handleAppleLogin(authResults)
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
        }
    }
    
    private func handleAppleLogin(_ authResults: ASAuthorization) {
            switch authResults.credential {
            case let appleIDCredential as ASAuthorizationAppleIDCredential:
                // 사용자 정보 추출
                let userIdentifier = appleIDCredential.user
                let fullName = appleIDCredential.fullName
                let email = appleIDCredential.email
                
                // 주의: fullName과 email은 최초 로그인 시에만 제공됩니다.
                // 서버에 저장하거나 AppStorage 등에 보관해야 합니다.
                print("User ID: \(userIdentifier)")
                
                // 이후 백엔드 서버에 토큰을 보내 검증하는 로직을 수행합니다.
                
            default:
                break
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
                    .font(.title2)
                    .foregroundColor(.black)
                    .frame(width: 30, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.black)
                }
            }
        }
    }
}

#Preview {
    LoginView()
}

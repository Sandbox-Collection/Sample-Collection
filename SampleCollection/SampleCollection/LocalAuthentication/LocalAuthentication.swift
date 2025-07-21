//
//  Auth.swift
//  SampleCollection
//
//  Created by 이재훈 on 7/15/25.
//

import SwiftUI
import LocalAuthentication

struct LocalAuthenticationView: View {
    var body: some View {
        ZStack {
            Button {
                Task { await authenticate() }
            } label: {
                Text("로그인 요청")
            }
        }
    }
    
    func authenticate() async {
        let context = LAContext()
        var error: NSError?
        
        // 지정된 정책에 따라 인증을 진행할 수 있는지를 평가 (현재 디바이스 상태나 사용자 설정이 해당 인증을 지원하는지 확인)
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithCompanion, error: &error)
        else {
            guard let error = error as? LAError
            else {
                print(error?.localizedDescription ?? "unknown Error")
                return
            }
            print("error.code: \(error.code.rawValue) \(error.userInfo[NSDebugDescriptionErrorKey] ?? "Unknown Error")")
            return
        }
        let reason: String
        // 기기가 지원하는 생체 인증의 종류
        // biometryType은 canEvaluatePolicy(_:error:) 메서드를 호출한 이후에만 유효한 값으로 설정 (초기값은 .none)
        switch context.biometryType {
        case .faceID:
            reason = "Face ID로 로그인 합니다."
        case .opticID:
            reason = "홍채로 로그인 합니다."
        case .touchID:
            reason = "지문으로 로그인 합니다."
        default:
            fatalError("알 수 없는 방법으로 로그인을 시도합니다.")
        }
        do {
            // 지정된 인증 정책(LAPolicy)을 비동기적으로 평가하여, 인증이 성공했는지 여부를 Bool로 반환
            let result = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithCompanion, // 평가할 인증 정책
                localizedReason: reason // 사용자에게 보여줄 인증 요청 이유
            )
            /*
             만약 async하지 않는 completion 방법으로 구현할 경우 주의할 점
             - reply 클로저는 내부 비공개 스레드에서 실행됨 (main queue 아님)
             - 이 클로저 안에서는 절대 canEvaluatePolicy(_:error:)를 호출하면 안 됨
             → 교착 상태(Deadlock) 발생 위험이 있음
             */
            print("로그인 성공 여부: \(result)")
        } catch {
            print("error: \(error) \(error.localizedDescription)")
        }
    }
}

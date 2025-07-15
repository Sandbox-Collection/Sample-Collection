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


/*
 ** LAPolicy **
 
 deviceOwnerAuthentication
 - 생체 인증 + Apple Watch 인증 + 기기 암호 인증까지 모두 허용하는 범용 정책
 - 생체 인증이 가능하면 우선 사용하고, macOS에선 Apple Watch 병렬 인증도 시도
 - 불가능할 경우 기기 암호/비밀번호 입력 유도
 
 deviceOwnerAuthenticationWithBiometrics
 - Face ID, Touch ID, 또는 Optic ID 등 생체 인증만 허용
 - 생채 인증 실패 시, 바로 종료
 - 실패가 반복되면 생체 인증 자체가 시스템 전체에서 비활성화됨 → 암호 입력 필요 (암호는 fallback(대체 수단)으로 직접 처리해야 함 > userFallback 에러 발생)
 
 deviceOwnerAuthenticationWithCompanion
 - 기기 소유자를 Apple Watch, Mac 등의 근처의 페어링된 컴패니언 디바이스로 인증하는 방식
 - 근처 페이링된 디바이스를 통해 사용자 인증
 - 이 정책을 사용할 경우, 페어링된 근처 디바이스(예: Apple Watch, Mac 등)를 통해 인증을 시도
    - 만약 사용 가능한 컴패니언 디바이스가 없으면, LAError.CompanionNotAvailable 오류가 발생
    - 인증은 사용자에게 컴패니언 디바이스에서 진행하라는 안내를 통해 이루어짐
    - 예: Apple Watch에 “iPhone 인증 요청” 팝업이 뜸
    - 또는 Mac에서 확인 요청이 표시됨
    주의 사항
    - canEvaluatePolicy(.deviceOwnerAuthenticationWithCompanion, ...)로 먼저 사용 가능 여부를 확인해야 함
    - 디바이스 간 proximity(근접성), 페어링 상태, 로그인 상태 등이 인증 성공 여부에 영향을 줌
    - 생체 인증이 아닌, 다른 기기 기반의 신뢰 기반 인증이라는 점이 핵심
 
 deviceOwnerAuthenticationWithBiometricsOrCompanion
 - 생채 인증 실패 시, 근처 페어링 된 디바이스를 통해 사용자 인증
 */

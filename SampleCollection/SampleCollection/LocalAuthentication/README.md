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

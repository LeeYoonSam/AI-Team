---
description: 보안 취약점 분석 및 OWASP 점검을 수행합니다.
argument-hint: [all|<파일경로>]
allowed-tools: Read, Grep, Glob, Bash
model: sonnet
---

# 보안 리뷰

## 리뷰 대상
$ARGUMENTS

## 보안 점검 프로세스

### 1. 코드 스캔

**하드코딩된 시크릿 검색**:
```bash
grep -rn "password\s*=\s*['\"]" --include="*.{ts,js,py,java}"
grep -rn "api_key\s*=\s*['\"]" --include="*.{ts,js,py,java}"
grep -rn "secret\s*=\s*['\"]" --include="*.{ts,js,py,java}"
```

**인젝션 취약점 검색**:
```bash
grep -rn "query.*\$\{" --include="*.ts"
grep -rn "innerHTML" --include="*.{ts,tsx,js,jsx}"
grep -rn "eval(" --include="*.{ts,js}"
```

### 2. OWASP Top 10 점검

1. **A01: Broken Access Control**
   - 권한 검사 누락 확인
   - 직접 객체 참조 취약점

2. **A02: Cryptographic Failures**
   - 약한 암호화 알고리즘 사용
   - 하드코딩된 키

3. **A03: Injection**
   - SQL 인젝션
   - XSS
   - 명령어 인젝션

4. **A04: Insecure Design**
   - 설계 수준 보안 결함

5. **A05: Security Misconfiguration**
   - 기본 설정 사용
   - 불필요한 기능 활성화

6. **A06: Vulnerable Components**
   - 취약한 의존성

7. **A07: Authentication Failures**
   - 약한 인증
   - 세션 관리 결함

8. **A08: Integrity Failures**
   - 무결성 검증 누락

9. **A09: Logging Failures**
   - 불충분한 로깅

10. **A10: SSRF**
    - 서버 측 요청 위조

### 3. 의존성 취약점 확인
```bash
npm audit  # Node.js
pip-audit  # Python
```

## 출력 형식

```markdown
# 보안 감사 리포트

## 감사 개요
- 대상: {대상}
- 일시: {일시}
- 범위: {범위}

## 위험도 요약

| 위험도 | 발견 수 |
|-------|--------|
| Critical | 0 |
| High | 0 |
| Medium | 0 |
| Low | 0 |

## 발견 사항

### [위험도] {제목}
**ID**: SEC-{번호}
**위치**: `{파일}:{라인}`
**CWE**: CWE-{번호}
**설명**: {설명}
**영향**: {영향}
**권장 수정**: {수정 방법}

## 의존성 취약점
| 패키지 | 버전 | 취약점 | 심각도 | 수정 버전 |
|--------|------|--------|--------|----------|

## 권장사항
1. 즉시: ...
2. 단기: ...
3. 중기: ...
```

## 산출물

**파일**: `state/outputs/security-{timestamp}.md`
